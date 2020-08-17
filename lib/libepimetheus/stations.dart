import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:epimetheus/libepimetheus/structures/art_item.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class Station extends ArtItem {
  final String stationId;
  final String title;
  final bool isShuffle;
  final bool isThumbprint;
  final bool canDelete;
  final bool canRename;

  const Station._internal({
    @required String pandoraId,
    @required this.stationId,
    @required this.title,
    @required this.isShuffle,
    @required this.isThumbprint,
    @required this.canDelete,
    @required this.canRename,
    @required artUrls,
  }) : super(pandoraId, artUrls);

  @override
  bool operator ==(Object other) => other is Station ? stationId == other.stationId && pandoraId == other.pandoraId && isShuffle == other.isShuffle && isThumbprint == other.isThumbprint && canRename == other.canDelete && canRename == other.canRename : super == (other);

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
    ))['tracks'];

    List<Song> playlistFragment = playlistFragmentJSON.map((songJSON) => Song(Map<String, dynamic>.from(songJSON))).toList();
    playlistFragment.removeWhere((Song song) => song.trackType == TrackType.artistMessage);
    return playlistFragment;
  }

  Future<FeedbackListSegment> getFeedback({
    @required User user,
    @required bool positive,
    @required int pageSize,
    int startIndex = 0,
  }) async {
    final feedbackListSegmentJSON = await makeApiRequest(
      version: 'v1',
      endpoint: 'station/getStationFeedback',
      requestData: {
        'pageSize': pageSize,
        'positive': positive,
        'startIndex': startIndex,
        'stationId': stationId,
      },
      user: user,
    );

    return FeedbackListSegment(feedbackListSegmentJSON['total'], (feedbackListSegmentJSON['feedback'] as List<dynamic>).map<Feedback>((feedbackJSON) => Feedback(Map<String, dynamic>.from(feedbackJSON))).toList(growable: false));
  }
}

Future<List<Station>> getStations(User user, bool includeShuffle) async {
  List<dynamic> stationsJSON = (await makeApiRequest(
    version: 'v1',
    endpoint: 'station/getStations',
    requestData: {'pageSize': 250},
    user: user,
  ))['stations'];

  if (includeShuffle) {
    stationsJSON.add(await makeApiRequest(
      version: 'v1',
      endpoint: 'station/shuffle',
      user: user,
    ));
  }

  return stationsJSON.map((stationJSON) {
    final isThumbprint = stationJSON['isThumbprint'];
    return Station._internal(
      pandoraId: stationJSON['pandoraId'],
      stationId: stationJSON['stationId'],
      title: stationJSON['name'],
      isShuffle: stationJSON['isShuffle'],
      isThumbprint: isThumbprint,
      canDelete: stationJSON['allowDelete'],
      canRename: stationJSON['allowRename'],
      artUrls: createArtMapFromDecodedJSON(stationJSON['art'], isThumbprint),
    );
  }).toList(growable: false);
}
