import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

class AuthStorage {
  final _secureStorage = const FlutterSecureStorage();

  static const _keyJwt = 'jwt_token';
  static const _keyDeviceId = 'device_id';
  static const _keyCompanyId = 'company_id';
  static const _keyCachedUsers = 'cached_users';

  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_keyDeviceId);

    if (deviceId == null || deviceId.isEmpty) {
      deviceId = "POS-${const Uuid().v4()}";
      await prefs.setString(_keyDeviceId, deviceId);
    }

    return deviceId;
  }

  Future<void> saveMasterSession(String jwt, int companyId) async {
    await _secureStorage.write(key: _keyJwt, value: jwt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCompanyId, companyId);
  }

  Future<String?> getJwt() async {
    return await _secureStorage.read(key: _keyJwt);
  }

  Future<int?> getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCompanyId);
  }

  Future<void> unlinkDevice() async {
    await _secureStorage.delete(key: _keyJwt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompanyId);
    await prefs.remove(_keyCachedUsers);
  }

  Future<bool> isDeviceRegistered() async {
    final jwt = await getJwt();
    final companyId = await getCompanyId();
    return jwt != null && jwt.isNotEmpty && companyId != null;
  }

  Future<void> saveCachedUsers(List<dynamic> usersJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCachedUsers, jsonEncode(usersJson));
  }

  Future<List<dynamic>?> getCachedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersStr = prefs.getString(_keyCachedUsers);
    if (usersStr != null && usersStr.isNotEmpty) {
      return jsonDecode(usersStr) as List<dynamic>;
    }
    return null;
  }
}
