// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_form_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LoginFormStore on _LoginFormStore, Store {
  Computed<bool> _$canLogInComputed;

  @override
  bool get canLogIn =>
      (_$canLogInComputed ??= Computed<bool>(() => super.canLogIn,
              name: '_LoginFormStore.canLogIn'))
          .value;

  final _$emailAtom = Atom(name: '_LoginFormStore.email');

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  final _$passwordAtom = Atom(name: '_LoginFormStore.password');

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  final _$emailErrorMessageAtom =
      Atom(name: '_LoginFormStore.emailErrorMessage');

  @override
  String get emailErrorMessage {
    _$emailErrorMessageAtom.reportRead();
    return super.emailErrorMessage;
  }

  @override
  set emailErrorMessage(String value) {
    _$emailErrorMessageAtom.reportWrite(value, super.emailErrorMessage, () {
      super.emailErrorMessage = value;
    });
  }

  final _$passwordErrorMessageAtom =
      Atom(name: '_LoginFormStore.passwordErrorMessage');

  @override
  String get passwordErrorMessage {
    _$passwordErrorMessageAtom.reportRead();
    return super.passwordErrorMessage;
  }

  @override
  set passwordErrorMessage(String value) {
    _$passwordErrorMessageAtom.reportWrite(value, super.passwordErrorMessage,
        () {
      super.passwordErrorMessage = value;
    });
  }

  final _$_LoginFormStoreActionController =
      ActionController(name: '_LoginFormStore');

  @override
  void validateEmail(String email) {
    final _$actionInfo = _$_LoginFormStoreActionController.startAction(
        name: '_LoginFormStore.validateEmail');
    try {
      return super.validateEmail(email);
    } finally {
      _$_LoginFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void validatePassword(String password) {
    final _$actionInfo = _$_LoginFormStoreActionController.startAction(
        name: '_LoginFormStore.validatePassword');
    try {
      return super.validatePassword(password);
    } finally {
      _$_LoginFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  bool validateAll() {
    final _$actionInfo = _$_LoginFormStoreActionController.startAction(
        name: '_LoginFormStore.validateAll');
    try {
      return super.validateAll();
    } finally {
      _$_LoginFormStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
email: ${email},
password: ${password},
emailErrorMessage: ${emailErrorMessage},
passwordErrorMessage: ${passwordErrorMessage},
canLogIn: ${canLogIn}
    ''';
  }
}
