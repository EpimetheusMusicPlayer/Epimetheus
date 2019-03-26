import 'package:epimetheus/libepimetheus/art_item.dart';
import 'package:epimetheus/libepimetheus/artists.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/networking.dart';
import 'package:epimetheus/libepimetheus/songs.dart';
import 'package:meta/meta.dart';

abstract class Recommendation extends ArtItem {
  final String pandoraId;
  final String title;
  final int listenerCount;

  Recommendation._internal({
    @required this.pandoraId,
    @required this.title,
    @required this.listenerCount,
    @required Map<int, String> artUrls,
  }) : super(artUrls);
}

class ArtistRecommendation extends Recommendation {
  final String detailUrl;

  ArtistRecommendation._internal({
    String pandoraId,
    String title,
    int listenerCount,
    Map<int, String> artUrls,
    this.detailUrl,
  }) : super._internal(pandoraId: pandoraId, title: title, listenerCount: listenerCount, artUrls: artUrls);

  factory ArtistRecommendation(Map<String, dynamic> artistJSON) {
    return ArtistRecommendation._internal(
      pandoraId: artistJSON['pandoraId'],
      title: artistJSON['name'],
      listenerCount: artistJSON['listenerCount'],
      artUrls: createArtMapFromDecodedJSON(artistJSON['art']),
    );
  }
}

class GenreStationRecommendation extends Recommendation {
  final String description;
  final List<Track> sampleTracks;
  final List<Artist> sampleArtists;
  final Map<int, String> headerArt;

  GenreStationRecommendation._internal({
    @required String pandoraId,
    @required String title,
    @required this.description,
    @required this.sampleTracks,
    @required this.sampleArtists,
    @required int listenerCount,
    @required Map<int, String> artUrls,
    @required this.headerArt,
  }) : super._internal(pandoraId: pandoraId, title: title, listenerCount: listenerCount, artUrls: artUrls);

  factory GenreStationRecommendation(Map<String, dynamic> genreStationJSON) {
    return GenreStationRecommendation._internal(
      pandoraId: genreStationJSON['pandoraId'],
      title: genreStationJSON['name'],
      description: genreStationJSON['description'],
      sampleTracks: genreStationJSON['sampleTracks'].map<Track>((trackJSON) => Track(trackJSON)).toList(growable: false),
      sampleArtists: genreStationJSON['sampleArtists'].map<Artist>((artistJSON) => Artist(artistJSON)).toList(growable: false),
      listenerCount: genreStationJSON['listenerCount'],
      artUrls: createArtMapFromDecodedJSON(genreStationJSON['art']),
      headerArt: createArtMapFromDecodedJSON(genreStationJSON['headerArt']),
    );
  }
}

class Recommendations {
  final List<ArtistRecommendation> artists;
  final List<GenreStationRecommendation> genreStations;

  Recommendations._internal({
    @required this.artists,
    @required this.genreStations,
  });
}

Future<Recommendations> getRecommendations(User user) async {
  Map<String, dynamic> recommendations = await makeApiRequest(
    version: 'v1',
    endpoint: 'search/getStationRecommendations',
    user: user,
    useProxy: user.usePortaller,
  );

  return Recommendations._internal(
    artists: recommendations['artists'].map<ArtistRecommendation>((artistJSON) => ArtistRecommendation(artistJSON)).toList(growable: false),
    genreStations: recommendations['genreStations']
        .map<GenreStationRecommendation>((genreStationJSON) => GenreStationRecommendation(genreStationJSON))
        .toList(growable: false),
  );
}
