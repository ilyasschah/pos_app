import 'dart:io';
import 'package:flutter/foundation.dart';

/// Sends a fire-and-forget HTTP POST to every configured Kitchen Display
/// tablet so they immediately re-fetch orders from the backend.
///
/// Each KDS tablet runs a lightweight HTTP server on [kdsPort].
/// The POS app calls [notify] after any order change.
class KitchenPushService {
  static const int kdsPort = 9090;
  static const String _refreshPath = '/refresh';

  /// Parses the comma-separated IPs stored in settings and notifies each.
  static void notifyFromSetting(String? settingValue) {
    if (settingValue == null || settingValue.trim().isEmpty) return;
    final ips = settingValue
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    notify(ips);
  }

  /// Sends a POST /refresh to each IP in parallel (non-blocking).
  static void notify(List<String> ips) {
    for (final ip in ips) {
      _ping(ip);
    }
  }

  static Future<void> _ping(String ip) async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 3)
        ..idleTimeout = const Duration(seconds: 3);
      final request = await client.post(ip, kdsPort, _refreshPath);
      request.headers.set('Content-Length', '0');
      final response = await request.close();
      await response.drain<void>();
      client.close(force: true);
    } catch (e) {
      debugPrint('[KDS] ping failed → $ip: $e');
    }
  }
}
