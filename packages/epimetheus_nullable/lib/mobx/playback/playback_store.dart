import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/features/playback/services/audio_task/audio_task.dart';
import 'package:epimetheus_nullable/mobx/api/api_store.dart';
import 'package:epimetheus_nullable/mobx/disposable_store.dart';
import 'package:iapetus/iapetus.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart';

part 'playback_store.g.dart';

class PlaybackStore = _PlaybackStore with _$PlaybackStore;

abstract class _PlaybackStore with Store implements DisposableStore {
  final ApiStore _apiStore;

  _PlaybackStore({@required ApiStore apiStore}) : _apiStore = apiStore;

  @observable
  Color dominantColor;

  @computed
  bool get isDominantColorDark =>
      (dominantColor?.computeLuminance() ?? 0) < 0.33;

  StreamSubscription<List<MediaItem>> _queueSubscription;
  StreamSubscription<MediaItem> _mediaItemSubscription;
  final Map<String, Color> _dominantColors = {};

  @override
  void init() {
    _startListening();
  }

  @override
  void dispose() {
    _stopListening();
  }

  void _startListening() {
    _queueSubscription = AudioService.queueStream.listen(_onQueueChanged);
    _mediaItemSubscription =
        AudioService.currentMediaItemStream.listen(_onMediaItemChanged);
  }

  void _stopListening() {
    _queueSubscription.cancel();
    _mediaItemSubscription.cancel();
  }

  void _onQueueChanged(List<MediaItem> queue) {
    // If the queue has been destroyed, clear everything.
    if (queue == null) {
      _dominantColors.clear();
    }

    // Scan the new queue and store the pandoraIds that haven't been handled
    // yet.
    final newPandoraIds = [
      for (final mediaItem in queue
          .where((mediaItem) => !_dominantColors.containsKey(mediaItem.id)))
        mediaItem.id
    ];

    // If there are no new IDs, end here.
    if (newPandoraIds.isEmpty) return;

    // Add the new IDs to the map, and initialise them all as null to begin
    // with.
    for (final pandoraId in newPandoraIds) {
      _dominantColors[pandoraId] = null;
    }

    // Fetch the media annotations, and use their dominant color values.
    _apiStore.api.getAnnotationsFromPandoraIds(newPandoraIds).then(
      (annotations) {
        for (final annotation
            in annotations.values.whereType<MediaAnnotation>()) {
          print(
            'Fetched color for ${annotation.name}: 0x${annotation.art.dominantColor?.toRadixString(16)?.toUpperCase()}',
          );
          final dominantColor = annotation.art.dominantColor;
          if (annotation.art.dominantColor != null) {
            _dominantColors[annotation.pandoraId] = Color(dominantColor);
          }
        }
      },
    ).catchError(
      (e) {
        // Do nothing on a network error.
        // The dominant colors for the requested items will remain null.
      },
      test: (e) => e is IapetusNetworkException,
    ).catchError(
      (e) {
        // If the listener's credentials have changed, stop listening to
        // anything and process a null media item.
        _stopListening();
        _onMediaItemChanged(null);
      },
      test: (e) => e is InvalidAuthException,
    );

    // Remove old dominant colors that belong to items in the queue.
    _dominantColors.removeWhere((pandoraId, color) =>
        queue.indexWhere((mediaItem) => mediaItem.id == pandoraId) == -1);
  }

  @action
  void _onMediaItemChanged(MediaItem mediaItem) {
    // If the media item isn't real media, clear the dominant color.
    if (mediaItem == null || mediaItem.id == AudioTask.loadingMediaItemId) {
      dominantColor = null;
      return;
    }

    dominantColor = _dominantColors[mediaItem.id];
  }
}
