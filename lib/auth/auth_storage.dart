import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Provide this globally so any screen can access device credentials
final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

class AuthStorage {
  final _secureStorage = const FlutterSecureStorage();

  // Keys
  static const _keyJwt = 'jwt_token';
  static const _keyDeviceId = 'device_id';
  static const _keyCompanyId = 'company_id';

  /// Gets the unique Device ID. If one doesn't exist, it generates and saves it permanently.
  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_keyDeviceId);

    if (deviceId == null || deviceId.isEmpty) {
      // Generate a new UUID for this specific iPad/Computer
      deviceId = "POS-${const Uuid().v4()}";
      await prefs.setString(_keyDeviceId, deviceId);
    }

    return deviceId;
  }

  /// Saves the Master JWT and Company ID after a successful Admin Login
  Future<void> saveMasterSession(String jwt, int companyId) async {
    await _secureStorage.write(key: _keyJwt, value: jwt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCompanyId, companyId);
  }

  /// Retrieves the JWT for API calls
  Future<String?> getJwt() async {
    return await _secureStorage.read(key: _keyJwt);
  }

  /// Retrieves the saved Company ID
  Future<int?> getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCompanyId);
  }

  /// THE DEV BUTTON: Completely unlinks the device (Factory Reset)
  Future<void> unlinkDevice() async {
    await _secureStorage.delete(key: _keyJwt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompanyId);
    // Note: We deliberately DO NOT delete the Device ID.
    // This physical device keeps its ID forever unless the app is uninstalled.
  }

  /// Checks if the device is currently registered to a company
  Future<bool> isDeviceRegistered() async {
    final jwt = await getJwt();
    final companyId = await getCompanyId();
    return jwt != null && jwt.isNotEmpty && companyId != null;
  }
}
