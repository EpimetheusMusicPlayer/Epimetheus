import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';

/// This class contains static methods used for communication between the main
/// app code and the audio task.
class AudioTaskCommunicator {
  /// The class is not meant to be instantiated, as isolates are used on some
  /// platforms and no memory is shared between them.
  AudioTaskCommunicator._();

  // True if an isolate is being used.
  static late final _usesIsolate = AudioService.usesIsolate;

  // Isolate-related properties.
  static const _portName = 'audio_task';
  static late final _receivePort = ReceivePort();

  // Non-isolate related properties.
  static late final _nonIsolateStreamController =
      StreamController<dynamic>.broadcast();

  /// Registers the communicator.
  static late final register =
      _usesIsolate ? _registerIsolate : _registerNonIsolate;

  /// Unregisters the communicator.
  static late final unregister =
      _usesIsolate ? _unregisterIsolate : _unregisterNonIsolate;

  /// Adds a message.
  static late final void Function(dynamic message) add = _usesIsolate
      ? IsolateNameServer.lookupPortByName(_portName)!.send
      : _nonIsolateStreamController.add;

  static Stream<dynamic> _registerIsolate() {
    IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _portName,
    );
    return _receivePort;
  }

  static void _unregisterIsolate() {
    IsolateNameServer.removePortNameMapping(_portName);
  }

  static Stream<dynamic> _registerNonIsolate() {
    return _nonIsolateStreamController.stream;
  }

  static void _unregisterNonIsolate() {}
}
