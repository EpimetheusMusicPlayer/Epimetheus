import 'package:epimetheus/audio/launch_helpers.dart';
import 'package:epimetheus/dialogs/dialogs.dart';
import 'package:epimetheus/libepimetheus/playlists.dart';
import 'package:epimetheus/pages/collection/paged_collection_tab.dart';
import 'package:epimetheus/widgets/playable/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlaylistsTab extends PagedCollectionTab<Playlist> {
  const PlaylistsTab() : super(buildSeparators: true);

  @override
  Widget itemListTileBuilder(
    BuildContext context,
    Playlist playlist,
    int index,
    PositionStorer storePosition,
    MenuShower showMenu,
    VoidCallback launch,
  ) {
    return InkWell(
      onTapDown: storePosition,
      onTap: () => Navigator.of(context).pushNamed('/playlist/${playlist.pandoraId}', arguments: [playlist.name, playlist.description]),
      onLongPress: () => showMenu<void>(),
      child: PlaylistListTile(
        playlist,
        onPlayPress: () {
          if (NeedsPremiumDialog.checkPremium(
            context: context,
            action: 'play playlists',
          )) {
            if (kIsWeb) {
              showEpimetheusDialog(
                dialog: UnsupportedPlatformDialog(
                  context: context,
                  action: 'Playing playlists',
                ),
              );
            } else {
              launchMusicProviderFromId<Playlist>(context, playlist.pandoraId);
            }
          }
        },
      ),
    );
  }

  @override
  Widget separatorBuilder(BuildContext context, int index) => const SizedBox();
}
