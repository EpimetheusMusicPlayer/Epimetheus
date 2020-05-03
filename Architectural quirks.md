# Architectural quirks
Epimetheus is a complicated app, especially for an app created with Flutter.
State management is not one of Flutter's strong suits.
This file outlines some nonobvious (yes, [that's a word](https://www.merriam-webster.com/dictionary/nonobvious)) quirks in Epimetheus's architecture.

- Song art caching
  - Epimetheus uses song art everywhere.  It's shown in the media notification, and in the now playing screen/banners, and it's also used to generate colors to style some UI elements.
    To generate these colors, a listener is notified when the song queue updates (in `ColorModel`), and colors are generated for all the upcoming songs.
  - As a result of this, upcoming song art is downloaded to the cache whenever the queue updates.
  - This means that all the art preloading is done in the `ColorModel` class's listener, and not in the `audio_task.dart` file like you might expect. The `audio_service` plugin's inbuilt caching is disabled.