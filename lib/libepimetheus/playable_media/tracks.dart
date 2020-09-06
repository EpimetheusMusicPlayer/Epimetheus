import 'package:epimetheus/libepimetheus/structures/collection/track_entity_creator.dart';
import 'package:epimetheus/libepimetheus/tracks.dart';

const _entityCreator = const TrackEntityCreator(null, null);

/// Note: the file at [audioUrl] is XOR-encypted with the base64-encoded [key].
class PlayableTrack {
  final Track track;
  final int index;
  final String audioUrl;
  final String key;
  final int gain;

  PlayableTrack._internal({
    this.track,
    this.index,
    this.audioUrl,
    this.key,
    this.gain,
  });

  static PlayableTrack createFromMap(Map<String, dynamic> map) {
    final itemMap = map['item'];
    return PlayableTrack._internal(
      track: _entityCreator.createItem(map['annotations'][itemMap['pandoraId']]),
      index: itemMap['index'],
      audioUrl: itemMap['audioUrl'],
      key: itemMap['key'],
      gain: int.tryParse(itemMap['fileGain'] ?? '0'),
    );
  }
}
