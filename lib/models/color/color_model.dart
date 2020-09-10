import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/libepimetheus/tracks.dart';
import 'package:epimetheus/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ColorModel extends Model {
  StreamSubscription<List<MediaItem>> _queueListener;
  StreamSubscription<MediaItem> _currentMediaItemListener;

  final Map<String, Color> _dominantColors = {};
  final Map<String, Future<Map<String, Color>>> _dominantColorFutures = {};

  Color _dominantColor;

  Color get dominantColor => _dominantColor;

  Color _readableForegroundColor;

  Color get readableForegroundColor => _readableForegroundColor;

  UserModel _userModel;

  void init(UserModel userModel) {
    _userModel = userModel;
    _queueListener = AudioService.queueStream.listen((queue) {
      // If there are pending colors, they'll be added to the map after the future completes.
      // This isn't a huge issue, as they'll be cleared when the queue next updates.
      if (queue == null || queue.isEmpty) {
        _dominantColors.clear();
        setBackgroundColor(null);
        return;
      }

      if (_userModel.user == null) return;

      final pandoraIds = queue
          .where(
            (mediaItem) => !_dominantColorFutures.containsKey(mediaItem.id) && !_dominantColors.containsKey(mediaItem.id),
          )
          .map((mediaItem) => mediaItem.id)
          .toList(growable: false);

      final future = Track.getDominantColorFromIds(
        userModel.user,
        pandoraIds,
      )..then((dominantColors) {
          _dominantColors.addAll(dominantColors);
          _dominantColorFutures.remove(pandoraIds);
        });
      for (final pandoraId in pandoraIds) _dominantColorFutures[pandoraId] = future;

      if (AudioService.queue != null) {
        // If there are pending colors, they'll be added to the map after the future completes.
        // This isn't a huge issue, as they'll be cleared when the queue next updates.
        _dominantColors.removeWhere((pandoraId, color) => queue.indexWhere((mediaItem) => mediaItem.id == pandoraId) == -1);
      }
    });

    _currentMediaItemListener = AudioService.currentMediaItemStream.listen((mediaItem) {
      if (mediaItem != null && mediaItem.id != 'loading') setBackgroundColor(mediaItem.id);
    });
  }

  void dispose() {
    _queueListener.cancel();
    _currentMediaItemListener.cancel();
  }

  Future<void> _loadDominantColor(String pandoraId) async {
    if (!_dominantColors.containsKey(pandoraId)) {
      if (_dominantColorFutures.containsKey(pandoraId)) {
        await _dominantColorFutures[pandoraId];
      } else {
        _dominantColors[pandoraId] = (await Track.getDominantColorFromIds(_userModel.user, [pandoraId]))[pandoraId];
      }
    }
  }

  Future<void> setBackgroundColor(String pandoraId) async {
    if (pandoraId == null) {
      _dominantColor = null;
    } else {
      await _loadDominantColor(pandoraId);
      final dominantColor = _dominantColors[pandoraId];
      print('SETTING COLOR: $dominantColor');
      _dominantColor = dominantColor ?? const Color(0xAA111111);
    }

    _setReadableForegroundColor();

    notifyListeners();
  }

  void _setReadableForegroundColor() {
    if (_dominantColor == null) return null;
    _readableForegroundColor = _dominantColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  static ColorModel of(
    BuildContext context, {
    bool rebuildOnChange = false,
  }) =>
      ScopedModel.of<ColorModel>(
        context,
        rebuildOnChange: rebuildOnChange,
      );
}
