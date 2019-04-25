import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/libepimetheus/art_item.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'authentication.dart';

enum TrackType {
  TRACK,
  ARTIST_MESSAGE,
}

/// A static track object obtained from recommendations or search results.
class Track extends ArtItem {
  final String title;
  final String artistTitle;
  final String albumTitle;

  const Track._internal({
    @required String pandoraId,
    @required this.title,
    @required this.artistTitle,
    @required this.albumTitle,
    @required Map<int, String> artUrls,
  }) : super(pandoraId, artUrls);

  Track(Map<String, dynamic> trackJSON)
      : this._internal(
          pandoraId: trackJSON['pandoraId'],
          title: trackJSON['songTitle'],
          artistTitle: trackJSON['artistName'],
          albumTitle: trackJSON['albumTitle'],
          artUrls: createArtMapFromDecodedJSON(trackJSON['albumArt']),
        );
}

/// An object that holds feedback about a track
class Feedback extends Track {
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
    title,
    artistTitle,
    albumTitle,
    Map<int, String> artUrls,
  ) : super._internal(
          pandoraId: pandoraId,
          title: title,
          artistTitle: artistTitle,
          albumTitle: albumTitle,
          artUrls: artUrls,
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
          trackType: songJSON['trackType'] == 'Track' ? TrackType.TRACK : TrackType.ARTIST_MESSAGE,
          trackToken: songJSON['trackToken'],
          title: songJSON['songTitle'],
          artistTitle: songJSON['artistName'],
          albumTitle: songJSON['albumTitle'],
          rating: songJSON['rating'] == 1 ? Rating.newThumbRating(true) : Rating.newUnratedRating(RatingStyle.thumbUpDown),
          audioUrl: songJSON['audioURL'],
          artUrls: createArtMapFromDecodedJSON(songJSON['albumArt']),
        );

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
