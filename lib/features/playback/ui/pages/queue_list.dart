import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/core/ui/widgets/list_footer_message.dart';
import 'package:epimetheus/features/playback/entities/audio_task_keys.dart';
import 'package:epimetheus/features/playback/ui/widgets/media_item_list_tile.dart';
import 'package:epimetheus/features/playback/ui/widgets/nothing_playing_display.dart';
import 'package:flutter/material.dart';

class QueueListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _buildList(int playingIndex, List<MediaItem> queue) {
      final queueLength = queue.length;
      return ListView.separated(
        itemCount: queueLength + 1,
        itemBuilder: (context, index) {
          if (index == queueLength) {
            return const ListFooterMessage(
              'More items may be added as playback continues.',
            );
          }

          return MediaItemListTile(
            playing: index == playingIndex,
            mediaItem: queue[index],
            isExplicit:
                false, // No explicitness info is provided by Pandora here.
          );
        },
        separatorBuilder: (context, index) {
          if (index == queueLength - 1) return const Divider(height: 1);
          return MediaItemListTile.separator;
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
      ),
      body: StreamBuilder<List<MediaItem>?>(
        stream: AudioService.queueStream,
        initialData: AudioService.queue,
        builder: (context, queueSnapshot) {
          return StreamBuilder<MediaItem?>(
            stream: AudioService.currentMediaItemStream,
            initialData: AudioService.currentMediaItem,
            builder: (context, mediaItemSnapshot) {
              if (mediaItemSnapshot.data == null ||
                  queueSnapshot.data == null ||
                  queueSnapshot.data!.isEmpty) {
                return const NothingPlayingDisplay();
              }

              final playingIndex = mediaItemSnapshot.data!
                  .extras[AudioTaskMetadataKeys.currentlyPlayingQueueIndex];

              return _buildList(playingIndex, queueSnapshot.data!);
            },
          );
        },
      ),
    );
  }
}
