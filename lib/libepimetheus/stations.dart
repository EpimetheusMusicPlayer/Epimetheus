import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:meta/meta.dart';

import './art_item.dart';
import './authentication.dart';
import './networking.dart';

class Station extends ArtItem {
  final String stationId;
  final String pandoraId;
  final String title;
  final bool isShuffle;
  final bool isThumbprint;
  final bool canDelete;
  final bool canRename;

  Station._internal({
    @required this.stationId,
    @required this.pandoraId,
    @required this.title,
    @required this.isShuffle,
    @required this.isThumbprint,
    @required this.canDelete,
    @required this.canRename,
    @required artUrls,
  }) : super(artUrls);

  @override
  bool operator ==(Object other) => other is Station
      ? stationId == other.stationId &&
          pandoraId == other.pandoraId &&
          isShuffle == other.isShuffle &&
          isThumbprint == other.isThumbprint &&
          canRename == other.canDelete &&
          canRename == other.canRename
      : super == (other);

  @override
  int get hashCode {
    var result = stationId.hashCode;
    result = 31 * result + pandoraId.hashCode;
    result = 31 * result + isShuffle.hashCode;
    result = 31 * result + isThumbprint.hashCode;
    result = 31 * result + canDelete.hashCode;
    result = 31 * result + canRename.hashCode;
    return result;
  }

  @override
  String toString() => 'name: $title, isShuffle: $isShuffle, isThumbprint: $isThumbprint, canDelete: $canDelete, canRename: $canRename';

  Future<List<Song>> getPlaylistFragment(User user) async {
    List<dynamic> playlistFragmentJSON = (await makeApiRequest(
      version: 'v1',
      endpoint: 'playlist/getFragment',
      requestData: {
        'stationId': stationId,
        'isStationStart': false,
        'fragmentRequestReason': 'Normal',
        'audioFormat': 'aacplus',
        'startingAtTrackId': null,
        'onDemandArtistMessageArtistUidHex': null,
        'onDemandArtistMessageIdHex': null,
      },
      user: user,
      useProxy: user.usePortaller,
    ))['tracks'];

    List<Song> playlistFragment = playlistFragmentJSON.map((songJSON) => Song(Map<String, dynamic>.from(songJSON))).toList();
    playlistFragment.removeWhere((Song song) => song.trackType == TrackType.ARTIST_MESSAGE);
    return playlistFragment;
  }
}

Future<List<Station>> getStations(User user, bool includeShuffle) async {
  List<dynamic> stationsJSON = (await makeApiRequest(
    version: 'v1',
    endpoint: 'station/getStations',
    requestData: {'pageSize': 4096},
    user: user,
    useProxy: user.usePortaller,
  ))['stations'];

  if (includeShuffle) {
    stationsJSON.add(await makeApiRequest(
      version: 'v1',
      endpoint: 'station/shuffle',
      user: user,
      useProxy: user.usePortaller,
    ));
  }

  return stationsJSON.map((stationJSON) {
    return Station._internal(
      stationId: stationJSON['stationId'],
      pandoraId: stationJSON['pandoraId'],
      title: stationJSON['name'],
      isShuffle: stationJSON['isShuffle'],
      isThumbprint: stationJSON['isThumbprint'],
      canDelete: stationJSON['allowDelete'],
      canRename: stationJSON['allowRename'],
      artUrls: createArtMapFromDecodedJSON(stationJSON['art']),
    );
  }).toList(growable: false);
}
