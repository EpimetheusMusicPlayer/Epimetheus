import 'package:epimetheus/features/auth/entities/auth_entities.dart';
import 'package:epimetheus_nullable/mobx/api/api_store.dart';
import 'package:iapetus/iapetus.dart';
import 'package:meta/meta.dart';
import 'package:mobx/mobx.dart' hide Listener;

part 'auth_store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

/// This store handles authentication; logging in and out.
///
/// It holds the currently logged in [listener], which can be used in the UI.
/// It also exposes an [authStatus], as well as
/// error-related observables.
abstract class _AuthStore with Store {
  final ApiStore apiStore;

  /// Constructs the store.
  /// An [ApiStore] is required, to be used for authentication.
  _AuthStore({
    @required this.apiStore,
  });

  @observable
  bool _loggingIn = false;

  /// The currently logged in [Listener]. May be null if no listener is logged
  /// in; check [authStatus] first.
  @observable
  Listener listener;

  /// If there's an error authenticating, the error message will be stored here.
  /// Check [hasError] to see if there's an error first.
  @observable
  Object error;

  /// Describes the authentication status.
  @computed
  AuthStatus get authStatus => error == null
      ? _loggingIn
          ? AuthStatus.loggingIn
          : listener == null
              ? AuthStatus.loggedOut
              : AuthStatus.loggedIn
      : AuthStatus.error;

  /// Performs the given login action, handling errors and updating observables
  /// accordingly.
  ///
  /// [login] may return null if a login is not possible at the time (due to
  /// missing stored credentials, for example).
  ///
  /// May throw exceptions like [InvalidAuthException] or [IapetusNetworkException].
  /// These should be handled by the UI.
  @action
  Future<void> _doLogin(Future<Listener> Function() login) async {
    assert(apiStore.apiInitialized, 'Iapetus is not initialized!');
    assert(!_loggingIn, 'Already logging in!');
    error = null;
    _loggingIn = true;
    try {
      listener = await login();
    } on IapetusNetworkException catch (e) {
      _loggingIn = false;
      error = e;
      return;
    } on InvalidAuthException catch (e) {
      _loggingIn = false;
      error = e;
      return;
    } on LocationException catch (e) {
      _loggingIn = false;
      error = e;
      return;
    } on UnknownPandoraErrorException catch (e) {
      _loggingIn = false;
      error = e;
    } finally {
      _loggingIn = false;
    }
  }

  /// Starts the login process with the given email and password.
  void startLogin({
    @required String email,
    @required String password,
  }) {
    assert(email != null);
    assert(password != null);
    _doLogin(
      () async {
        // TODO catch proxy errors
        await apiStore.configureProxy();
        final api = apiStore.api;
        await api.login(
          email: email,
          password: password,
        );
        return api.listener;
      },
    );
  }

  /// Starts the login process with credentials in storage.
  void startLoginFromStorage() {
    _doLogin(() async {
      final api = apiStore.api;
      final loginSuccessful = await api.loginFromStorage();
      return loginSuccessful ? api.listener : null;
    });
  }

  /// Logs the listener out.
  @action
  Future<void> logout() async {
    await apiStore.api.logout();
    listener = null;
  }
}
