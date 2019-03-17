package tk.hacker1024.qudio

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.util.Log
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.ConcatenatingMediaSource
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.MediaSourceEventListener
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.lang.IllegalArgumentException

class QudioPlugin(context: Context, val channel: MethodChannel) : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "tk.hacker1024.qudio")
            channel.setMethodCallHandler(
                QudioPlugin(
                    registrar.activeContext().applicationContext,
                    channel
                )
            )
        }
    }

    private val player = ExoPlayerFactory.newSimpleInstance(context)
    private val dataSourceFactory = ExtractorMediaSource.Factory(
        DefaultDataSourceFactory(
            context,
            Util.getUserAgent(context, "qudio")
        )
    )
    private val concatenatingMediaSource = ConcatenatingMediaSource();

    init {
        player.addListener(object : Player.EventListener {
            override fun onLoadingChanged(isLoading: Boolean) {
                channel.invokeMethod("onLoadingChanged", isLoading)
            }

            override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                Log.d("QUDIO", "Player state changed") // TODO checking this
                channel.invokeMethod(
                    "onPlayerStateChanged",
                    mapOf(
                        "playWhenReady" to playWhenReady,
                        "playbackState" to playbackState
                    )
                )
            }

            override fun onPositionDiscontinuity(reason: Int) {
                Log.d("QUDIO", "Discontinuity")
                concatenatingMediaSource.removeMediaSourceRange(0, player.currentPeriodIndex)
                channel.invokeMethod("onPositionDiscontinuity", reason)
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "begin" -> {
                Log.d("QUDIO", "Begin")
                player.prepare(concatenatingMediaSource)
                player.playWhenReady = true
                result.success(true)
            }

            "addToQueue" -> {
                Log.d("QUDIO", "Add")
                val index = call.argument<Int>("index")

                if (index == null) {
                    concatenatingMediaSource.addMediaSource(
                        dataSourceFactory.createMediaSource(
                            Uri.parse(
                                call.argument<String>("uri")
                            )
                        )
                    )
                } else {
                    concatenatingMediaSource.addMediaSource(
                        index,
                        dataSourceFactory.createMediaSource(
                            Uri.parse(
                                call.argument<String>("uri")
                            )
                        )
                    )
                }

                result.success(true);
            }

            "addAllToQueue" -> {
                Log.d("QUDIO", "AddAll")
                val index = call.argument<Int>("index")

                if (index == null) {
                    concatenatingMediaSource.addMediaSources(
                        call.argument<List<String>>("uris")!!.map {
                            dataSourceFactory.createMediaSource(Uri.parse(it))
                        }
                    )
                } else {
                    concatenatingMediaSource.addMediaSources(
                        index,
                        call.argument<List<String>>("uris")!!.map {
                            dataSourceFactory.createMediaSource(Uri.parse(it))
                        }
                    )
                }

                result.success(true)
            }

            "removeFromQueue" -> {
                Log.d("QUDIO", "Remove")
                try {
                    concatenatingMediaSource.removeMediaSource(call.argument<Int>("index")!!)
                    result.success(true)
                } catch (e: IllegalArgumentException) {
                    result.success(false)
                }
            }

            "removeRangeFromQueue" -> {
                Log.d("QUDIO", "RemoveRange")
                try {
                    concatenatingMediaSource.removeMediaSourceRange(
                        call.argument<Int>("fromIndex")!!,
                        call.argument<Int>("toIndex")!!
                    )
                    result.success(true)
                } catch (e: IllegalArgumentException) {
                    result.success(false)
                }
            }

            "pause" -> {
                Log.d("QUDIO", "Pause")
                player.playWhenReady = false
                result.success(true)
            }
            "play" -> {
                Log.d("QUDIO", "Play")
                player.playWhenReady = true
                result.success(true)
            }
            "seekTo" -> {
                try {
                    player.seekTo(call.argument<Number>("position")!!.toLong())
                    result.success(true)
                } catch (e: IllegalSeekPositionException) {
                    result.success(false)
                }
            }
            "fastForward" -> {
                try {
                    player.seekTo(player.currentPosition + call.argument<Int>("amount")!!)
                    result.success(true)
                } catch (e: IllegalSeekPositionException) {
                    result.success(false)
                }
            }
            "rewind" -> {
                try {
                    player.seekTo(player.currentPosition - call.argument<Int>("amount")!!)
                    result.success(true)
                } catch (e: IllegalSeekPositionException) {
                    result.success(false)
                }
            }
            "skip" -> {
                if (player.hasNext()) {
                    player.next()
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "skipTo" -> {
                try {
                    player.seekToDefaultPosition(call.argument<Int>("index")!!)
                    result.success(true)
                } catch (e: IllegalSeekPositionException) {
                    result.success(false)
                }
            }
            "stop" -> {
                player.stop(true)
                concatenatingMediaSource.clear()
                result.success(true)
            }

            "getDuration" -> result.success(
                player.duration.run { if (this == C.TIME_UNSET) null else this }
            )
            "getPosition" -> result.success(player.currentPosition)

            "getQueueSize" -> result.success(concatenatingMediaSource.size)
        }
    }
}
