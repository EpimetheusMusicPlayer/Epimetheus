// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AuthStore on _AuthStore, Store {
  final _$authStateAtom = Atom(name: '_AuthStore.authState');

  @override
  AuthState get authState {
    _$authStateAtom.reportRead();
    return super.authState;
  }

  @override
  set authState(AuthState value) {
    _$authStateAtom.reportWrite(value, super.authState, () {
      super.authState = value;
    });
  }

  final _$_doLoginAsyncAction = AsyncAction('_AuthStore._doLogin');

  @override
  Future<void> _doLogin(Future<PandoraCredentials> Function(Iapetus) getCreds) {
    return _$_doLoginAsyncAction.run(() => super._doLogin(getCreds));
  }

  final _$logoutAsyncAction = AsyncAction('_AuthStore.logout');

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  @override
  String toString() {
    return '''
authState: ${authState}
    ''';
  }
}
