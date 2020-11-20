import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/features/navigation/ui/widgets/navigation_drawer.dart';
import 'package:epimetheus/features/playback/ui/widgets/embedded_media_controls.dart';
import 'package:epimetheus/features/playback/ui/widgets/nothing_playing_display.dart';
import 'package:epimetheus/features/playback/ui/widgets/queue_display.dart';
import 'package:epimetheus/routes.dart';
import 'package:epimetheus_nullable/mobx/playback/playback_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

class NowPlayingPage extends StatelessWidget {
  // https://github.com/flutter/flutter/issues/61618
  // https://github.com/flutter/flutter/issues/50606#issuecomment-662216140
  static final _lightAppBarTheme = AppBarTheme(
    brightness: Brightness.light,
    textTheme:
        Typography.material2018().black.merge(Typography.englishLike2018),
    iconTheme: const IconThemeData(color: Colors.black87),
    actionsIconTheme: const IconThemeData(color: Colors.black87),
  );

  static final _darkAppBarTheme = AppBarTheme(
    brightness: Brightness.dark,
  );

  final playbackStore = GetIt.instance<PlaybackStore>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: AudioService.runningStream,
      builder: (context, snapshot) {
        if (snapshot.data == null) return const SizedBox();
        final isAudioServiceRunning = snapshot.data!;
        return Observer(
          builder: (context) {
            final dominantColor =
                playbackStore.dominantColor ?? Theme.of(context).primaryColor;
            final isDominantColorDark = playbackStore.isDominantColorDark;

            return Theme(
              data: Theme.of(context).copyWith(
                appBarTheme:
                    isDominantColorDark ? _darkAppBarTheme : _lightAppBarTheme,
              ),
              child: Scaffold(
                drawer:
                    NavigationDrawer(currentRouteName: RouteNames.nowPlaying),
                appBar: AppBar(
                  title: const Text('Now Playing'),
                  elevation: isAudioServiceRunning ? 0 : null,
                  backgroundColor:
                      isAudioServiceRunning ? Colors.transparent : null,
                ),
                body: isAudioServiceRunning
                    ? NowPlayingContent(
                        dominantColor: dominantColor,
                        isDominantColorDark: isDominantColorDark,
                      )
                    : const NothingPlayingDisplay(),
                extendBodyBehindAppBar: true,
              ),
            );
          },
        );
      },
    );
  }
}

class NowPlayingContent extends StatelessWidget {
  final Color dominantColor;
  final bool isDominantColorDark;

  const NowPlayingContent({
    Key? key,
    required this.dominantColor,
    required this.isDominantColorDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: dominantColor,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: QueueDisplay(
                  dominantColor: dominantColor,
                  isDominantColorDark: isDominantColorDark,
                ),
              ),
              const EmbeddedMediaControls(dynamicColors: true),
            ],
          ),
        ),
      ),
    );
  }
}
