import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/features/navigation/reactions.dart';
import 'package:epimetheus/features/playback/reactions.dart';
import 'package:epimetheus/injection_container.dart';
import 'package:epimetheus/routes.dart';
import 'package:epimetheus/stores.dart';
import 'package:epimetheus/theme.dart';
import 'package:epimetheus_nullable/mobx/api/api_store.dart';
import 'package:epimetheus_nullable/mobx/auth/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

void main() async {
  // Initialize dependency injection.
  await initDi();

  // Initialize disposable stores.
  initStores();

  // Initialize the [Iapetus] library.
  await GetIt.instance<ApiStore>().initializeApi();

  // Attempt to log in from storage before launching the UI.
  // This results in the UI launching when the status is [AuthStatus.loggingIn],
  // so the UI can navigate accordingly when a new state is set.
  GetIt.instance<AuthStore>().startLoginFromStorage();

  // Launch the UI.
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late final _navigatorKey = GlobalKey<NavigatorState>();
  late final List<ReactionDisposer> _reactionDisposers;

  /// Pop the entire stack and navigates to the given route name.
  void _navigateBackTo(String routeName, [Object? arguments]) {
    _navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (_) => false,
      arguments: arguments,
    );
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      // UI reactions.
      _reactionDisposers = [
        ...setupNavigationReactions(
          _navigatorKey.currentContext!,
          _navigateBackTo,
        ),
        ...setupPlaybackReactions(),
      ];
    });
  }

  @override
  void dispose() {
    // Dispose of reactions.
    for (final d in _reactionDisposers) {
      d();
    }

    // Dispose of global or reactive stores (in the service locator).
    // While the stores are created in [main] rather than [initState],
    // The app ends when this widget's state is disposed, so the stores are
    // disposed of here.
    disposeStores();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(
      child: MaterialApp(
        title: 'Epimetheus',
        theme: themeData,
        darkTheme: darkThemeData,
        navigatorKey: _navigatorKey,
        routes: routes,
      ),
    );
  }
}
