import 'package:epimetheus/features/auth/entities/auth_status.dart';
import 'package:epimetheus/features/proxy/entities/exceptions.dart';
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

  /// The currently logged in [Listener]. May be null if no listener is logged
  /// in; check [authStatus] first.
  Listener get listener => apiStore.api.listener;

  @observable
  AuthState authState = const AuthState.loggedOut();

  /// Performs the given login action, handling errors and updating observables
  /// accordingly.
  ///
  /// [getCreds] may return null if no credentials exist. The function will stop
  /// and return if this happens.
  ///
  /// May throw exceptions like [InvalidAuthException] or [IapetusNetworkException].
  /// These should be handled by the UI.
  @action
  Future<void> _doLogin(
    Future<PandoraCredentials> Function(Iapetus api) getCreds,
  ) async {
    assert(apiStore.apiInitialized, 'Iapetus is not initialized!');
    assert(authState.status != AuthStatus.loggingIn, 'Already logging in!');

    // Set the state to logging in.
    authState = const AuthState.loggingIn();

    // Get the API object.
    final api = apiStore.api;

    // Retrieve the credentials, aborting if they're null.
    final creds = await getCreds(api);
    if (!creds.hasRequiredLoginCredentials) return;

    try {
      // Configure the proxy.
      await apiStore.configureProxy();

      // Do the login.
      await api.login(creds);

      // Assert that a listener is now set, and set the state to logged in.
      assert(listener != null, 'Login finished, but listener is null!');
      authState = AuthState.loggedIn(creds);
    } on ProxyException catch (e) {
      authState = AuthState.error(creds, e);
    } on IapetusNetworkException catch (e) {
      authState = AuthState.error(creds, e);
    } on InvalidAuthException catch (e) {
      authState = AuthState.error(creds, e);
    } on LocationException catch (e) {
      authState = AuthState.error(creds, e);
    } on UnknownPandoraErrorException catch (e) {
      authState = AuthState.error(creds, e);
    }
  }

  /// Starts the login process with the given credentials.
  void startLogin(PandoraCredentials creds) {
    _doLogin((_) async => creds);
  }

  /// Starts the login process with credentials in storage.
  void startLoginFromStorage() {
    _doLogin((api) => api.getStoredCredentials());
  }

  /// Logs the listener out.
  @action
  Future<void> logout() async {
    await apiStore.api.logout();
    authState = const AuthState.loggedOut();
  }
}
