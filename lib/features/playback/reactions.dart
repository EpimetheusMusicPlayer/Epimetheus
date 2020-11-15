import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/features/auth/entities/auth_entities.dart';
import 'package:epimetheus_nullable/mobx/auth/auth_store.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

List<ReactionDisposer> setupPlaybackReactions() {
  final authStore = GetIt.instance<AuthStore>();
  return [
    reaction<AuthStatus>(
      (_) => authStore.authStatus,
      _handleAuthStatusChanges,
    ),
  ];
}

/// Stops the service on logout.
void _handleAuthStatusChanges(AuthStatus status) async {
  if (status == AuthStatus.loggedOut) {
    final wasConnected = AudioService.connected;
    await AudioService.connect();
    await AudioService.stop();
    if (!wasConnected) await AudioService.disconnect();
  }
}
