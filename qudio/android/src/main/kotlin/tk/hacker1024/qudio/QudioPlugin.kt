package tk.hacker1024.qudio

import android.content.Context
import android.net.Uri
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.ConcatenatingMediaSource
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

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
                channel.invokeMethod(
                    "onPlayerStateChanged",
                    mapOf(
                        "playWhenReady" to playWhenReady,
                        "playbackState" to playbackState
                    )
                )
            }

            override fun onPositionDiscontinuity(reason: Int) {
                concatenatingMediaSource.removeMediaSourceRange(0, player.currentPeriodIndex)
                channel.invokeMethod("onPositionDiscontinuity", reason)
            }

            override fun onPlayerError(error: ExoPlaybackException) {
                channel.invokeMethod("onSourceError", null)
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "begin" -> {
                player.prepare(concatenatingMediaSource)
                player.playWhenReady = true
                result.success(true)
            }

            "addToQueue" -> {
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
                try {
                    concatenatingMediaSource.removeMediaSource(call.argument<Int>("index")!!)
                    result.success(true)
                } catch (e: IllegalArgumentException) {
                    result.success(false)
                }
            }

            "removeRangeFromQueue" -> {
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
                player.playWhenReady = false
                result.success(true)
            }
            "play" -> {
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
