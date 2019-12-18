import 'package:epimetheus/audio/audio_task.dart';
import 'package:epimetheus/audio/providers/station_music_provider.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/models/collection/collection.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:flutter/widgets.dart';

void launchStation(BuildContext context, int stationIndex) {
  final user = UserModel.of(context).user;
  final stations = CollectionModel.of(context).stationCollectionProvider.getAsync(user);

  if (stations == null) return;

  launchMusicProvider(
    user,
    StationMusicProvider(
      stations,
      stationIndex,
    ),
  );
}

void launchTrack(BuildContext context, Track track) {
  print('Launching track: ${track.title}');
}
