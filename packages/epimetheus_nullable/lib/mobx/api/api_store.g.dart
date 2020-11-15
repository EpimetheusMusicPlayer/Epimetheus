// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ApiStore on _ApiStore, Store {
  Computed<bool> _$apiInitializedComputed;

  @override
  bool get apiInitialized =>
      (_$apiInitializedComputed ??= Computed<bool>(() => super.apiInitialized,
              name: '_ApiStore.apiInitialized'))
          .value;

  final _$apiAtom = Atom(name: '_ApiStore.api');

  @override
  Iapetus get api {
    _$apiAtom.reportRead();
    return super.api;
  }

  @override
  set api(Iapetus value) {
    _$apiAtom.reportWrite(value, super.api, () {
      super.api = value;
    });
  }

  final _$initializeApiAsyncAction = AsyncAction('_ApiStore.initializeApi');

  @override
  Future<void> initializeApi() {
    return _$initializeApiAsyncAction.run(() => super.initializeApi());
  }

  @override
  String toString() {
    return '''
api: ${api},
apiInitialized: ${apiInitialized}
    ''';
  }
}
