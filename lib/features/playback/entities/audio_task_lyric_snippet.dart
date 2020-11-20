import 'package:iapetus/iapetus.dart';

const _linesKey = 'lines';
const _creditsKey = 'credits';
const _lyricIdKey = 'lyricId';
const _checksumKey = 'checksum';
const _nonExplicitKey = 'nonExplicit';

/// A [LyricSnippet] provided by the audio task. Can be serialised in
/// [MediaItem] extras.
class AudioTaskLyricSnippet extends LyricSnippet {
  AudioTaskLyricSnippet.fromMap(Map<dynamic, dynamic> map)
      : super(
          lines: List.unmodifiable(map[_linesKey]),
          credits: List.unmodifiable(map[_creditsKey]),
          lyricId: map[_lyricIdKey],
          checksum: map[_checksumKey],
          nonExplicit: map[_nonExplicitKey],
        ) {
    print('Creating!');
  }
}

extension AudioTaskLyricSnippetExtensions on LyricSnippet {
  Map<String, dynamic> toMap() {
    return {
      _linesKey: lines,
      _creditsKey: credits,
      _lyricIdKey: lyricId,
      _checksumKey: checksum,
      _nonExplicitKey: nonExplicit,
    };
  }
}
