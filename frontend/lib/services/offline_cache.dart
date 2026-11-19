import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Copia local de las respuestas de la carta pública para poder consultarla sin conexión.
class OfflineCache {
  static const _prefix = 'offline_v1:';

  static Future<void> save(String key, Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$key', jsonEncode({'saved_at': DateTime.now().toIso8601String(), 'body': body}));
    } catch (_) {}
  }

  static Future<({Map<String, dynamic> body, DateTime savedAt})?> read(String key) async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString('$_prefix$key');
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (body: json['body'] as Map<String, dynamic>, savedAt: DateTime.parse(json['saved_at'] as String));
    } catch (_) {
      return null;
    }
  }
}
