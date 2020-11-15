// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AuthStore on _AuthStore, Store {
  Computed<AuthStatus> _$authStatusComputed;

  @override
  AuthStatus get authStatus =>
      (_$authStatusComputed ??= Computed<AuthStatus>(() => super.authStatus,
              name: '_AuthStore.authStatus'))
          .value;

  final _$_loggingInAtom = Atom(name: '_AuthStore._loggingIn');

  @override
  bool get _loggingIn {
    _$_loggingInAtom.reportRead();
    return super._loggingIn;
  }

  @override
  set _loggingIn(bool value) {
    _$_loggingInAtom.reportWrite(value, super._loggingIn, () {
      super._loggingIn = value;
    });
  }

  final _$listenerAtom = Atom(name: '_AuthStore.listener');

  @override
  Listener get listener {
    _$listenerAtom.reportRead();
    return super.listener;
  }

  @override
  set listener(Listener value) {
    _$listenerAtom.reportWrite(value, super.listener, () {
      super.listener = value;
    });
  }

  final _$errorAtom = Atom(name: '_AuthStore.error');

  @override
  Object get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(Object value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  final _$_doLoginAsyncAction = AsyncAction('_AuthStore._doLogin');

  @override
  Future<void> _doLogin(Future<Listener> Function() login) {
    return _$_doLoginAsyncAction.run(() => super._doLogin(login));
  }

  final _$logoutAsyncAction = AsyncAction('_AuthStore.logout');

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  @override
  String toString() {
    return '''
listener: ${listener},
error: ${error},
authStatus: ${authStatus}
    ''';
  }
}
