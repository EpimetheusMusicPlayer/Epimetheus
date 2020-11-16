import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SecureStorage {
  Future<void> _init();

  Future<String> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  static Future<SecureStorage> create() async {
    final secureStorage = !kIsWeb && (Platform.isAndroid || Platform.isIOS)
        ? const NativeSecureStorage._()
        : FallbackSecureStorage._();

    await secureStorage._init();
    return secureStorage;
  }
}

class NativeSecureStorage implements SecureStorage {
  const NativeSecureStorage._();

  static const _storage = FlutterSecureStorage();

  @override
  Future<void> _init() async {}

  @override
  Future<String> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class FallbackSecureStorage implements SecureStorage {
  FallbackSecureStorage._();

  late final SharedPreferences _prefs;

  @override
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<String> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> delete(String key) => _prefs.remove(key);
}
