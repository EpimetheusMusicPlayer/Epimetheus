import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/libepimetheus/art_item.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'authentication.dart';

enum TrackType {
  track, // Track
  artistMessage, // ??
}

enum TrackExplicitness {
  explicit, // EXPLICIT
  none, // NONE
}

enum TrackSortOrder {
  alpha, // ALPHA
  dateAdded, // MOST_RECENT_ADDED
}

/// A static track object.
class Track extends ArtItem {
  final String title;
  final int trackNumber;
  final String albumId;
  final String albumTitle;
  final String artistId;
  final String artistTitle;
  final int duration;
  final TrackExplicitness explicitness;

  const Track._internal({
    @required String pandoraId,
    @required this.title,
    @required this.trackNumber,
    @required this.albumId,
    @required this.albumTitle,
    @required this.artistId,
    @required this.artistTitle,
    @required this.duration,
    @required this.explicitness,
    @required Map<int, String> artUrls,
  }) : super(pandoraId, artUrls);

  Track(String pandoraId, Map<String, dynamic> annotationJSON)
      : this._internal(
          pandoraId: pandoraId,
          title: annotationJSON['name'],
          trackNumber: annotationJSON['trackCount'],
          albumId: annotationJSON['albumId'],
          albumTitle: annotationJSON['albumName'],
          artistId: annotationJSON['artistId'],
          artistTitle: annotationJSON['artistName'],
          duration: annotationJSON['duration'],
          explicitness: annotationJSON['explicitness'] == 'EXPLICIT' ? TrackExplicitness.explicit : TrackExplicitness.none,
          artUrls: {
            500: 'https://content-images.p-cdn.com/${annotationJSON['icon']['thorId']}',
          },
        );
}

Future<List<Track>> getTracks({
  @required User user,
  @required TrackSortOrder sortOrder,
  @required int offset,
  int pageSize = 24,
}) async {
  final trackListJSON = await makeApiRequest(
    version: 'v5',
    endpoint: 'collections/getSortedTracks',
    requestData: {
      'request': {
        'sortOrder': sortOrder == TrackSortOrder.alpha ? 'ALPHA' : 'MOST_RECENT_ADDED',
        'offset': offset,
        'limit': pageSize,
        'annotationLimit': pageSize,
      },
    },
    useProxy: user.useProxy,
    user: user,
  );

  final tracksJSON = trackListJSON['items'];
  final annotationsJSON = trackListJSON['annotations'];
  final tracks = List<Track>(tracksJSON.length);

  for (int i = 0; i < tracks.length; ++i) {
    final String pandoraId = tracksJSON[i]['pandoraId'];
    tracks[i] = (Track(pandoraId, annotationsJSON[pandoraId]));
  }

  return tracks;
}

/// An object that holds feedback about a track
class Feedback extends ArtItem {
  final String title;
  final String artistTitle;
  final String albumTitle;

  String _feedbackId;

  String get feedbackId => _feedbackId;

  Rating _rating;

  Rating get rating => _rating;

  Rating _pendingRating = const Rating.newUnratedRating(RatingStyle.thumbUpDown);

  Rating get pendingRating => _pendingRating;

  Feedback._internal(
    pandoraId,
    this._feedbackId,
    this._rating,
    this.title,
    this.artistTitle,
    this.albumTitle,
    Map<int, String> artUrls,
  ) : super(
          pandoraId,
          artUrls,
        );

  Feedback(Map<String, dynamic> feedbackJSON)
      : this._internal(
          feedbackJSON['pandoraId'],
          feedbackJSON['feedbackId'],
          Rating.newThumbRating(feedbackJSON['isPositive']),
          feedbackJSON['songTitle'],
          feedbackJSON['artistName'],
          feedbackJSON['albumTitle'],
          createArtMapFromDecodedJSON(feedbackJSON['albumArt']),
        );

  void updateFeedbackLocally(Rating rating) {
    _rating = rating;
  }

  Future<void> deleteFeedback(User user) async {
    if (!_rating.isRated()) {
      _feedbackId = null;
      return;
    }
    assert(_feedbackId != null || this is Song);
    _pendingRating = _rating;
    await makeApiRequest(
      version: 'v1',
      endpoint: 'station/deleteFeedback',
      requestData: {
        'feedbackId': _feedbackId ??= await (this as Song)._getFeedbackId(),
        'isPositive': _rating.isThumbUp(),
      },
      user: user,
      useProxy: user.useProxy,
    );
    _rating = const Rating.newUnratedRating(RatingStyle.thumbUpDown);
    _pendingRating = const Rating.newUnratedRating(RatingStyle.thumbUpDown);
  }
}

class FeedbackListSegment {
  final int total;

  int get length => segment.length;
  final List<Feedback> segment;

  const FeedbackListSegment(this.total, this.segment);
}

/// A playable song object obtained from station playlist fragments.
class Song extends Feedback {
  final TrackType trackType;
  final String trackToken;
  final String audioUrl;

  Song._internal({
    @required pandoraId,
    @required this.trackType,
    @required this.trackToken,
    @required title,
    @required artistTitle,
    @required albumTitle,
    @required rating,
    @required this.audioUrl,
    @required Map<int, String> artUrls,
  }) : super._internal(
          pandoraId,
          null,
          rating,
          title,
          artistTitle,
          albumTitle,
          artUrls,
        );

  Song(Map<String, dynamic> songJSON)
      : this._internal(
          pandoraId: songJSON['pandoraId'],
          trackType: songJSON['trackType'] == 'Track' ? TrackType.track : TrackType.artistMessage,
          trackToken: songJSON['trackToken'],
          title: songJSON['songTitle'],
          artistTitle: songJSON['artistName'],
          albumTitle: songJSON['albumTitle'],
          rating: songJSON['rating'] == 1 ? Rating.newThumbRating(true) : Rating.newUnratedRating(RatingStyle.thumbUpDown),
          audioUrl: songJSON['audioURL'],
          artUrls: createArtMapFromDecodedJSON(songJSON['albumArt']),
        );

  // TODO doesn't this need a user function?
  Future<String> _getFeedbackId() async {
    assert(rating.isRated(), 'Rating is not rated!');
    return (await makeApiRequest(
      version: 'v1',
      endpoint: 'station/addFeedback',
      requestData: {
        'trackToken': trackToken,
        'isPositive': rating.isThumbUp(),
      },
    ))['feedbackId'];
  }

  Future<void> addFeedback(User user, bool positive) async {
    assert(positive != null);
    _pendingRating = Rating.newThumbRating(positive);
    final response = await makeApiRequest(
      version: 'v1',
      endpoint: 'station/addFeedback',
      requestData: {
        'trackToken': trackToken,
        'isPositive': positive,
      },
      user: user,
      useProxy: user.useProxy,
    );
    _feedbackId = response['feedbackId'];
    _rating = Rating.newThumbRating(response['isPositive']);
    _pendingRating = const Rating.newUnratedRating(RatingStyle.thumbUpDown);
  }
}
