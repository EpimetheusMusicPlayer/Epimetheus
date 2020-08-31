import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/libepimetheus/collections.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/libepimetheus/structures/art/static_art_item.dart';
import 'package:epimetheus/libepimetheus/structures/paged_collection_list.dart';
import 'package:epimetheus/libepimetheus/structures/pandora_entity.dart';
import 'package:epimetheus/libepimetheus/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'authentication.dart';

enum TrackType {
  track, // Track
  artistMessage, // ??
}

/// A static track object.
class Track extends PandoraEntity with StaticArtItem {
  final Map<int, String> artUrls;
  final String title;
  final int trackNumber;
  final String albumId;
  final String albumTitle;
  final String artistId;
  final String artistTitle;
  final Duration duration;
  final PandoraEntityExplicitness explicitness;
  final Color dominantColor;

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
    @required this.dominantColor,
    @required this.artUrls,
    @required PandoraEntityType type,
  }) : super(pandoraId, type);

  static Track createFromMaps(Map<String, dynamic> annotation, [Map<String, dynamic> collectionDetails]) {
    final icon = annotation['icon'];
    return Track._internal(
      pandoraId: annotation['pandoraId'],
      title: annotation['name'],
      trackNumber: annotation['trackCount'],
      albumId: annotation['albumId'],
      albumTitle: annotation['albumName'],
      artistId: annotation['artistId'],
      artistTitle: annotation['artistName'],
      duration: Duration(seconds: annotation['duration']),
      explicitness: annotation['explicitness'] == 'EXPLICIT' ? PandoraEntityExplicitness.explicit : PandoraEntityExplicitness.none,
      dominantColor: pandoraColorToColor(icon['dominantColor']),
      artUrls: {
        500: 'https://content-images.p-cdn.com/${icon['artUrl']}',
      },
      type: PandoraEntity.types[annotation['type']],
    );
  }

  static PagedCollectionList<Track> _createListFromMap(Map<String, dynamic> map) {
    return PagedCollectionList<Track>.createFromMap(map, createFromMaps, createDynamicEntityFromMaps);
  }

  static Future<PagedCollectionList<Track>> getTracks({
    @required User user,
    @required PagedCollectionListSortOrder sortOrder,
    @required int limit,
    @required int offset,
  }) async {
    return Track._createListFromMap(
      await getCollection(
        user: user,
        typePrefixes: const [PandoraEntityType.track],
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  String toString() {
    return '$title by $artistTitle ($albumTitle)';
  }
}

/// An object that holds feedback about a track
class Feedback extends PandoraEntity with StaticArtItem {
  final Map<int, String> artUrls;
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
    this.artUrls,
  ) : super(
          pandoraId,
          PandoraEntityType.track,
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
    );
    _feedbackId = response['feedbackId'];
    _rating = Rating.newThumbRating(response['isPositive']);
    _pendingRating = const Rating.newUnratedRating(RatingStyle.thumbUpDown);
  }
}
