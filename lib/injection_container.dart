import 'package:epimetheus_nullable/mobx/api/api_store.dart';
import 'package:epimetheus_nullable/mobx/auth/auth_store.dart';
import 'package:epimetheus_nullable/mobx/collection/collection_store.dart';
import 'package:epimetheus_nullable/mobx/playback/playback_store.dart';
import 'package:get_it/get_it.dart';

Future<void> initDi() async {
  // Stores
  GetIt.instance.registerSingleton(
    ApiStore(),
  );
  GetIt.instance.registerSingleton(
    AuthStore(
      apiStore: GetIt.instance.call(),
    ),
  );
  GetIt.instance.registerSingleton(
    CollectionStore(
      apiStore: GetIt.instance(),
      authStore: GetIt.instance(),
    ),
  );
  GetIt.instance.registerSingleton(
    PlaybackStore(
      apiStore: GetIt.instance(),
    ),
  );
}
