import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SecureStorageManager {
  SecureStorageManager._();

  Future<void> _init();

  Future<String> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class NativeSecureStorageManager extends SecureStorageManager {
  NativeSecureStorageManager._() : super._();

  static const _storage = const FlutterSecureStorage();

  @override
  Future<void> _init() async {}

  @override
  Future<String> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class FallbackSecureStorageManager extends SecureStorageManager {
  FallbackSecureStorageManager._() : super._();

  SharedPreferences _prefs;

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

Future<SecureStorageManager> getPlatformSecureStorageManager() async {
  SecureStorageManager _get() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return NativeSecureStorageManager._();
    }

    return FallbackSecureStorageManager._();
  }

  final secureStorageManager = _get();
  await secureStorageManager._init();
  return secureStorageManager;
}
