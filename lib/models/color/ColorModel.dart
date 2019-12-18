import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:scoped_model/scoped_model.dart';

class ColorModel extends Model {
  StreamSubscription<List<MediaItem>> _queueListener;

  final Map<String, PaletteGenerator> paletteGenerators = {};
  final Map<String, Future<PaletteGenerator>> _paletteGeneratorFutures = {};

  Color _backgroundColor;

  Color get backgroundColor => _backgroundColor;

  void init() {
    _queueListener = AudioService.queueStream.listen((queue) {
      // If there are pending palette generators, they'll be added to the map after it's cleared.
      // This isn't a huge issue, as they'll be cleared when the queue next updates.
      if (queue.isEmpty) {
        paletteGenerators.clear();
        setBackgroundColor(null);
        return;
      }

      for (MediaItem mediaItem in queue) {
        if (!paletteGenerators.containsKey(mediaItem.artUri)) {
          print('GENERATING FOR ${mediaItem.title}, ${mediaItem.artUri}');

          // Initialise the key so it doesn't launch multiple palette generator generations while the first is still generating
          paletteGenerators[mediaItem.artUri] = null;

          // Add the generator future to the map
          final future = PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(mediaItem.artUri));
          _paletteGeneratorFutures[mediaItem.artUri] = future;

          future.then((paletteGenerator) {
            // Set the palette generator
            paletteGenerators[mediaItem.artUri] = paletteGenerator;

            // Remove the future from the map
            _paletteGeneratorFutures.remove(mediaItem.artUri);
          });
        }
      }

      setBackgroundColor(queue[0].artUri);

      // If there are pending palette generators, they'll be added to the map after the null placeholder is removed.
      // This isn't a huge issue, as they'll be cleared when the queue next updates.
      for (int i = 0; i < paletteGenerators.length; ++i) {
        final key = paletteGenerators.keys.elementAt(i);
        if (queue.indexWhere((mediaItem) => mediaItem.artUri == key) == -1) {
          print('Removing $key');
          paletteGenerators.remove(key);
        }
      }
    });
  }

  void dispose() {
    _queueListener.cancel();
  }

  Future<void> _loadPaletteGenerator(String artUri) async {
    if (paletteGenerators.containsKey(artUri)) {
      if (_paletteGeneratorFutures.containsKey(artUri)) await _paletteGeneratorFutures[artUri];
      return;
    }

    print('NOT USING CACHED GENERATOR!!!');
    paletteGenerators[artUri] = await PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(artUri));
  }

  void setBackgroundColor(String artUri) async {
    if (artUri == null) {
      _backgroundColor = null;
    } else {
      await _loadPaletteGenerator(artUri);
      final paletteGenerator = paletteGenerators[artUri];

      if (paletteGenerator == null)
        _backgroundColor = null;
      else if (paletteGenerator.dominantColor != null)
        _backgroundColor = paletteGenerator.dominantColor.color;
      else if (paletteGenerator.darkMutedColor != null)
        _backgroundColor = paletteGenerator.darkMutedColor.color;
      else if (paletteGenerator.darkVibrantColor != null)
        _backgroundColor = paletteGenerator.darkVibrantColor.color;
      else
        _backgroundColor = null;
    }

    notifyListeners();
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

Color getReadableForegroundColor(Color backgroundColor) {
  if (backgroundColor == null) return null;
  return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
