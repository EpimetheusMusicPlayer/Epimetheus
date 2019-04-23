import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/libepimetheus/art_item.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

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

/// A playable song object obtained from station playlist fragments.
class Song extends Track {
  final TrackType trackType;
  final Rating rating;
  final String audioUrl;

  String feedbackId;

  Song._internal({
    @required pandoraId,
    @required this.trackType,
    @required title,
    @required artistTitle,
    @required albumTitle,
    @required this.rating,
    @required this.audioUrl,
    @required Map<int, String> artUrls,
  }) : super._internal(
          pandoraId: pandoraId,
          title: title,
          artistTitle: artistTitle,
          albumTitle: albumTitle,
          artUrls: artUrls,
        );

  Song(Map<String, dynamic> songJSON)
      : this._internal(
          pandoraId: songJSON['pandoraId'],
          trackType: songJSON['trackType'] == 'Track' ? TrackType.TRACK : TrackType.ARTIST_MESSAGE,
          title: songJSON['songTitle'],
          artistTitle: songJSON['artistName'],
          albumTitle: songJSON['albumTitle'],
          rating: songJSON['rating'] == 1 ? Rating.newThumbRating(true) : Rating.newUnratedRating(RatingStyle.thumbUpDown),
          audioUrl: songJSON['audioURL'],
          artUrls: createArtMapFromDecodedJSON(songJSON['albumArt']),
        );
}

/// An object that holds feedback about a track
class Feedback extends Track {
  final String feedbackId;
  final bool isPositive;

  const Feedback._internal({
    @required pandoraId,
    @required this.feedbackId,
    @required this.isPositive,
    @required title,
    @required artistTitle,
    @required albumTitle,
    @required Map<int, String> artUrls,
  }) : super._internal(
          pandoraId: pandoraId,
          title: title,
          artistTitle: artistTitle,
          albumTitle: albumTitle,
          artUrls: artUrls,
        );

  Feedback(Map<String, dynamic> feedbackJSON)
      : this._internal(
          pandoraId: feedbackJSON['pandoraId'],
          feedbackId: feedbackJSON['feedbackId'],
          isPositive: feedbackJSON['isPositive'],
          title: feedbackJSON['songTitle'],
          artistTitle: feedbackJSON['artistName'],
          albumTitle: feedbackJSON['albumTitle'],
          artUrls: createArtMapFromDecodedJSON(feedbackJSON['albumArt']),
        );
}

class FeedbackListSegment {
  final int total;
  int get length => segment.length;
  final List<Feedback> segment;

  const FeedbackListSegment(this.total, this.segment);
}
