import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/app_info.dart';
import 'package:epimetheus/features/playback/entities/audio_task_actions.dart';
import 'package:epimetheus/features/playback/entities/audio_task_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_visualizers/Visualizers/LineVisualizer.dart';
import 'package:flutter_visualizers/visualizer.dart';
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';

/// Audio visualizer widget (Android only). Work in progress. Currently broken,
/// and needs refactoring.
class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer();

  @override
  _AudioVisualizerState createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> {
  bool _permissionsGranted = false;
  late final StreamSubscription<dynamic> _subscription;
  late final _audioSessionIdStreamController = StreamController<int?>(
    onCancel: _subscription.cancel,
  );

  Future<void> _runPermissionDialog() async {
    final isGranted = await Permission.microphone.request().isGranted;
    if (isGranted && mounted) {
      setState(() {
        _permissionsGranted = true;
      });
    }
  }

  void _checkPermissions() async {
    if (!await Permission.microphone.isGranted) {
      if (await Permission.microphone.shouldShowRequestRationale) {
        SchedulerBinding.instance!.addPostFrameCallback(
          (_) async {
            final userChoice = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Enable the visualiser?'),
                  content: const Text(
                      'In order to display an aesthetic music visualiser, ${appName} needs the audio recording permission. ${appName} will never record any audio other than its own.'),
                  actions: [
                    TextButton(
                      child: const Text('No'),
                      onPressed: () {
                        Navigator.of(context)!.pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () {
                        Navigator.of(context)!.pop(true);
                      },
                    ),
                  ],
                );
              },
            );

            if (userChoice == null || !userChoice) return;

            if (await Permission.microphone.isPermanentlyDenied) {
              print(await openAppSettings());
            } else {
              unawaited(_runPermissionDialog());
            }
          },
        );
      } else {
        if (!await Permission.microphone.isPermanentlyDenied) {
          unawaited(_runPermissionDialog());
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _permissionsGranted = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    assert(!kIsWeb && Platform.isAndroid, 'Visualizer only works on Android!');
    _checkPermissions();
    AudioService.customAction(AudioTaskActions.getAndroidAudioSessionId)
        .then((id) => _audioSessionIdStreamController.add(id));
    _subscription = AudioService.customEventStream.listen((event) {
      if (event is AndroidAudioSessionIdChanged) {
        _audioSessionIdStreamController.add(event.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) return const SizedBox();

    print('Granted');

    return StreamBuilder<int?>(
      stream: _audioSessionIdStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.data == null) return const SizedBox();
        print('Got data!');
        return Visualizer(
          id: snapshot.data!,
          builder: (context, wave) {
            return CustomPaint(
              painter: LineVisualizer(
                waveData: wave,
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: 64,
              ),
            );
          },
        );
      },
    );
  }
}
