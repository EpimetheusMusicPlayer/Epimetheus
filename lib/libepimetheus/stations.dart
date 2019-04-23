import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import './art_item.dart';
import './authentication.dart';
import './networking.dart';

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

  // TODO finish writing this function
  // TODO this shouldn't be a static function, but it's gotta be like this until I find a way to access the audio task's current station from the UI isolate.
  static Future<FeedbackListSegment> getFeedback({
    @required User user,
    @required String stationId,
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
      useProxy: user.useProxy,
    );

    return FeedbackListSegment(
        feedbackListSegmentJSON['total'],
        (feedbackListSegmentJSON['feedback'] as List<dynamic>)
            .map<Feedback>((feedbackJSON) => Feedback(Map<String, dynamic>.from(feedbackJSON)))
            .toList(growable: false));
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
      useProxy: user.useProxy,
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
    useProxy: user.useProxy,
  ))['stations'];

  if (includeShuffle) {
    stationsJSON.add(await makeApiRequest(
      version: 'v1',
      endpoint: 'station/shuffle',
      user: user,
      useProxy: user.useProxy,
    ));
  }

  return stationsJSON.map((stationJSON) {
    return Station._internal(
      pandoraId: stationJSON['pandoraId'],
      stationId: stationJSON['stationId'],
      title: stationJSON['name'],
      isShuffle: stationJSON['isShuffle'],
      isThumbprint: stationJSON['isThumbprint'],
      canDelete: stationJSON['allowDelete'],
      canRename: stationJSON['allowRename'],
      artUrls: createArtMapFromDecodedJSON(stationJSON['art']),
    );
  }).toList(growable: false);
}
