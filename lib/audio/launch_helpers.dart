import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:flutter/widgets.dart';

void launchStation(BuildContext context, int stationIndex) {
//  final user = UserModel.of(context).user;
//  final stations = CollectionModel.of(context).stationCollectionProvider.getAsync(user);
//
//  if (stations == null) return;
//
//  launchMusicProvider(
//    user.clone()..discardClient(),
//    StationMusicProvider(
//      stations,
//      stationIndex,
//    ),
//  );
}

void launchTrack(BuildContext context, Track track) {
  print('Launching track: ${track.title}');
}
