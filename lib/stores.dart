import 'package:epimetheus_nullable/mobx/api/api_store.dart';
import 'package:epimetheus_nullable/mobx/collection/collection_store.dart';
import 'package:epimetheus_nullable/mobx/playback/playback_store.dart';
import 'package:get_it/get_it.dart';

/// Initialises stores in the service locator.
void initStores() {
  // The ApiStore is initialized by main.dart
  GetIt.instance<CollectionStore>().init();
  GetIt.instance<PlaybackStore>().init();
}

/// Disposes of any global or reactive stores (in the service locator).
/// This may never be called; the app may just exit instead.
void disposeStores() {
  GetIt.instance<ApiStore>().dispose();
  GetIt.instance<CollectionStore>().dispose();
  GetIt.instance<PlaybackStore>().dispose();
}
