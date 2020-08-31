/// An enum to represent some of the Pandora "object" types.
/// The types below are only the types used by this Dart code;
/// there may be more used by Pandora.
/// "ALL" is sometimes used in requests (like v6/collections/getSortedByTypes) to ask for all types to be returned.
enum PandoraEntityType {
  station, //           ST
  stationFactory, //    SF
  track, //             TR
  playlist, //          PL
  artist, //            AR
  album, //             AL
  listener, //          LI
}

/// An abstract class that defines some base properties that all "objects"
/// passed to and received from Pandora seem to have.
///
/// [pandoraId] is a unique ID that represents the "object".
/// [type] is the type of "object" represented by the [pandoraId].
abstract class PandoraEntity {
  final String pandoraId;
  final PandoraEntityType type;

  const PandoraEntity(this.pandoraId, this.type);

  static const Map<String, PandoraEntityType> types = {
    'ST': PandoraEntityType.station,
    'SF': PandoraEntityType.stationFactory,
    'TR': PandoraEntityType.track,
    'PL': PandoraEntityType.playlist,
    'AR': PandoraEntityType.artist,
    'AL': PandoraEntityType.album,
    'LI': PandoraEntityType.listener,
  };

  static const Map<PandoraEntityType, String> typeNames = {
    PandoraEntityType.station: 'ST',
    PandoraEntityType.stationFactory: 'SF',
    PandoraEntityType.track: 'TR',
    PandoraEntityType.playlist: 'PL',
    PandoraEntityType.artist: 'AR',
    PandoraEntityType.album: 'AL',
    PandoraEntityType.listener: 'LI',
  };
}

/// This enum defines explicitness levels. There are two known levels.
enum PandoraEntityExplicitness {
  explicit, // EXPLICIT
  none, // NONE
}
