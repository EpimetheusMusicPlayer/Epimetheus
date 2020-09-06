import 'package:epimetheus/audio/audio_task.dart';
import 'package:epimetheus/audio/providers/music_provider.dart';
import 'package:epimetheus/audio/providers/playlist_music_provider.dart';
import 'package:epimetheus/audio/providers/station_music_provider.dart';
import 'package:epimetheus/libepimetheus/playlists.dart';
import 'package:epimetheus/libepimetheus/stations.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/models/collection/collection_model.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:flutter/widgets.dart';

class UnknownMusicProviderTypeException implements Exception {}

MusicProvider _getMusicProvider<T extends PandoraEntity>({dynamic item, String pandoraId, List<T> catalogue}) {
  switch (T) {
    case Station:
      return StationMusicProvider(item, catalogue as List<Station>);
    case Playlist:
      return PlaylistMusicProvider(trackList: item, pandoraId: pandoraId);
    default:
      throw UnknownMusicProviderTypeException();
  }
}

void launchMusicProviderFromId<T extends PandoraEntity>(BuildContext context, String pandoraId) {
  final user = UserModel.of(context).user;
  // final collection = CollectionModel.of(context).getCollectionProvider<T>().downloaded;
  //
  // Search the existing collection for the item
  // if (collection != null) {
  //   for (var index = 0; index < collection.length; ++index) {
  //     final collectionItem = collection[index];
  //     if (collectionItem.pandoraId == pandoraId) {
  //       launchMusicProvider(
  //         user..discardClient(),
  //         _getMusicProvider<T>(item: collectionItem),
  //       );
  //     }
  //   }
  // }

  // If we get here, there's no item that's already downloaded. Pass the Pandora ID instead.
  launchMusicProvider(
    user.clone()..discardClient(),
    _getMusicProvider<T>(pandoraId: pandoraId),
  );
}

void launchMusicProviderFromCollection<T extends PandoraEntity>(BuildContext context, int index, {List<T> catalogue}) {
  final user = UserModel.of(context).user;
  final collection = CollectionModel.of(context).getCollectionProvider<T>().downloaded;

  if (collection == null) return;

  print('Launching ${collection[index].pandoraId}');

  try {
    launchMusicProvider(
      user.clone()..discardClient(),
      _getMusicProvider<T>(
        item: collection[index],
        catalogue: catalogue,
      ),
    );
  } on UnknownMusicProviderTypeException {
    // Fail silently
  }
}
