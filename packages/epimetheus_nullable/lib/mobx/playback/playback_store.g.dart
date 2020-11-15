// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PlaybackStore on _PlaybackStore, Store {
  Computed<bool> _$isDominantColorDarkComputed;

  @override
  bool get isDominantColorDark => (_$isDominantColorDarkComputed ??=
          Computed<bool>(() => super.isDominantColorDark,
              name: '_PlaybackStore.isDominantColorDark'))
      .value;

  final _$dominantColorAtom = Atom(name: '_PlaybackStore.dominantColor');

  @override
  Color get dominantColor {
    _$dominantColorAtom.reportRead();
    return super.dominantColor;
  }

  @override
  set dominantColor(Color value) {
    _$dominantColorAtom.reportWrite(value, super.dominantColor, () {
      super.dominantColor = value;
    });
  }

  final _$_PlaybackStoreActionController =
      ActionController(name: '_PlaybackStore');

  @override
  void _onMediaItemChanged(MediaItem mediaItem) {
    final _$actionInfo = _$_PlaybackStoreActionController.startAction(
        name: '_PlaybackStore._onMediaItemChanged');
    try {
      return super._onMediaItemChanged(mediaItem);
    } finally {
      _$_PlaybackStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
dominantColor: ${dominantColor},
isDominantColorDark: ${isDominantColorDark}
    ''';
  }
}
