import 'package:iapetus/iapetus.dart';

enum AuthStatus { loggedOut, loggingIn, loggedIn, error }

class AuthState {
  final AuthStatus status;
  final PandoraCredentials? creds;
  final dynamic error;

  const AuthState._({
    required this.status,
    this.creds,
    this.error,
  });

  const AuthState.loggedOut() : this._(status: AuthStatus.loggedOut);

  const AuthState.loggingIn() : this._(status: AuthStatus.loggingIn);

  const AuthState.loggedIn(PandoraCredentials creds)
      : this._(
          status: AuthStatus.loggedIn,
          creds: creds,
        );

  const AuthState.error(PandoraCredentials creds, dynamic error)
      : this._(
          status: AuthStatus.error,
          creds: creds,
          error: error,
        );
}
