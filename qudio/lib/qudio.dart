import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('tk.hacker1024.qudio');

enum QudioPlaybackState {
  /// The player does not have any media to play.
  STATE_IDLE,

  /// The player is not able to immediately play from its current position.
  /// This state typically occurs when more data needs to be loaded.
  STATE_BUFFERING,

  /// The player is able to immediately play from its current position.
  STATE_READY,

  /// The player has finished playing the media.
  STATE_ENDED,
}

class QudioPlaybackStatus {
  final bool playing;
  final QudioPlaybackState playbackState;

  const QudioPlaybackStatus._internal(this.playing, this.playbackState);
}

enum PositionDiscontinuityReason {
  /// A queue item finished.
  DISCONTINUITY_REASON_PERIOD_TRANSITION,

  /// The player skipped to a new queue item.
  DISCONTINUITY_REASON_SEEK,

  /// The player skipped to a new queue item.
  DISCONTINUITY_REASON_SEEK_ADJUSTMENT,

  /// An ad was inserted. Not supported by this plugin.
  DISCONTINUITY_REASON_AD_INSERTION,

  /// Discontinuity introduced internally by the queue source.
  DISCONTINUITY_REASON_INTERNAL,
}

class Qudio {
  static bool _connected = false;

  /// A stream broadcasting the player's playback status.
  static Stream<QudioPlaybackStatus> get playbackStatusStream => _playbackStatusStream.stream;
  static StreamController<QudioPlaybackStatus> _playbackStatusStream = StreamController<QudioPlaybackStatus>.broadcast();

  /// A variable containing the current playback status.
  static QudioPlaybackStatus get playbackStatus => _playbackStatus;
  static QudioPlaybackStatus _playbackStatus;

  /// A stream broadcasting the player's loading status.
  static Stream<bool> get isLoadingStream => _isLoadingStream.stream;
  static StreamController<bool> _isLoadingStream = StreamController<bool>.broadcast();

  /// A variable containing the current loading status.
  static bool get isLoading => _isLoading;
  static bool _isLoading = false;

  /// A stream broadcasting the player's transition events.
  static Stream<PositionDiscontinuityReason> get positionDiscontinuityStream => _positionDiscontinuityStream.stream;
  static StreamController<PositionDiscontinuityReason> _positionDiscontinuityStream = StreamController<PositionDiscontinuityReason>.broadcast();

  /// A stream broadcasting source (network) errors.
  static Stream<bool> get sourceErrorStream => _sourceErrorStream.stream;
  static StreamController<bool> _sourceErrorStream = StreamController<bool>.broadcast();

  static void connect() {
    if (!_connected) {
      _connected = true;
      _channel.setMethodCallHandler((MethodCall call) {
        switch (call.method) {
          case "onPlayerStateChanged":
            _playbackStatus = QudioPlaybackStatus._internal(
              call.arguments["playWhenReady"],
              QudioPlaybackState.values[call.arguments["playbackState"] - 1],
            );
            _playbackStatusStream.add(_playbackStatus);
            break;
          case "onLoadingChanged":
            _isLoading = call.arguments;
            _isLoadingStream.add(_isLoading);
            break;
          case "onPositionDiscontinuity":
            _positionDiscontinuityStream.add(PositionDiscontinuityReason.values[call.arguments]);
            break;
          case "onSourceError":
            _sourceErrorStream.add(true);
            break;
        }
      });
    }
  }

  static void disconnect() {
    if (_connected) {
      _connected = false;
      _channel.setMethodCallHandler(null);
      _playbackStatus = null;
      _isLoading = false;
    }
  }

  static Future<bool> begin() async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("begin");
  }

  static Future<bool> addToQueue(String uri, [int index]) async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("addToQueue", {
      "uri": uri,
      "index": index,
    });
  }

  static Future<bool> addAllToQueue(List<String> uris, [int index]) async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("addAllToQueue", {
      "uris": uris,
      "index": index,
    });
  }

  static Future<bool> removeFromQueue(int index) async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("removeFromQueue", {
      "index": index,
    });
  }

  static Future<bool> removeRangeFromQueue(int fromIndex, int toIndex) async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("removeRangeFromQueue", {
      "fromindex": fromIndex,
      "toIndex": toIndex,
    });
  }

  static Future<bool> pause() async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("pause");
  }

  static Future<bool> play() async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("play");
  }

  static Future<bool> seekTo(int position) async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("seekTo", {
      "position": position,
    });
  }

  static Future<bool> fastForward(int position) async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("fastForward", {
      "amount": position,
    });
  }

  static Future<bool> rewind(int position) async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("rewind", {
      "amount": position,
    });
  }

  static Future<bool> skip() async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("skip");
  }

  static Future<bool> skipTo(int index) async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("skipTo", {
      "index": index,
    });
  }

  static Future<bool> stop() async {
    if (!_connected) return Future.value(false);
    return await _channel.invokeMethod("stop");
  }

  static Future<int> get currentDuration async {
    if (!_connected) return Future.value(null);
    return await _channel.invokeMethod("getDuration");
  }

  static Future<int> get currentPosition async {
    if (!_connected) return Future.value(null);
    return await _channel.invokeMethod("getPosition");
  }

  static Future<int> get queueSize async {
    if (!_connected) return Future.value(null);
    return await _channel.invokeMethod("getQueueSize");
  }
}
