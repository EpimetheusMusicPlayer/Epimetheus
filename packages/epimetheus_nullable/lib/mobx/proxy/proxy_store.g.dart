// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ProxyStore on _ProxyStore, Store {
  final _$selectedProviderAtom = Atom(name: '_ProxyStore.selectedProvider');

  @override
  Type get selectedProvider {
    _$selectedProviderAtom.reportRead();
    return super.selectedProvider;
  }

  @override
  set selectedProvider(Type value) {
    _$selectedProviderAtom.reportWrite(value, super.selectedProvider, () {
      super.selectedProvider = value;
    });
  }

  final _$loadedAtom = Atom(name: '_ProxyStore.loaded');

  @override
  bool get loaded {
    _$loadedAtom.reportRead();
    return super.loaded;
  }

  @override
  set loaded(bool value) {
    _$loadedAtom.reportWrite(value, super.loaded, () {
      super.loaded = value;
    });
  }

  final _$loadingAtom = Atom(name: '_ProxyStore.loading');

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  final _$savingAtom = Atom(name: '_ProxyStore.saving');

  @override
  bool get saving {
    _$savingAtom.reportRead();
    return super.saving;
  }

  @override
  set saving(bool value) {
    _$savingAtom.reportWrite(value, super.saving, () {
      super.saving = value;
    });
  }

  final _$loadAsyncAction = AsyncAction('_ProxyStore.load');

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  final _$saveAsyncAction = AsyncAction('_ProxyStore.save');

  @override
  Future<void> save() {
    return _$saveAsyncAction.run(() => super.save());
  }

  @override
  String toString() {
    return '''
selectedProvider: ${selectedProvider},
loaded: ${loaded},
loading: ${loading},
saving: ${saving}
    ''';
  }
}
