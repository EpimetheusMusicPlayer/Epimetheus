import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/libepimetheus/art_item.dart';
import 'package:meta/meta.dart';

enum TrackType {
  TRACK,
  ARTIST_MESSAGE,
}

/// A static track object obtained from recommendations or search results.
class Track extends ArtItem {
  final String pandoraId;
  final String title;
  final String artistTitle;
  final String albumTitle;

  Track._internal({
    @required this.pandoraId,
    @required this.title,
    @required this.artistTitle,
    @required this.albumTitle,
    @required Map<int, String> artUrls,
  }) : super(artUrls);

  factory Track(Map<String, dynamic> trackJSON) {
    return Track._internal(
      pandoraId: trackJSON['pandoraId'],
      title: trackJSON['songTitle'],
      artistTitle: trackJSON['artistName'],
      albumTitle: trackJSON['albumTitle'],
      artUrls: createArtMapFromDecodedJSON(trackJSON['albumArt']),
    );
  }
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

  factory Song(Map<String, dynamic> songJSON) {
    return Song._internal(
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
}
