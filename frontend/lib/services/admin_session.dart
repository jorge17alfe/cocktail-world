import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cocktail_models.dart';

/// Sesión del administrador: token + local + usuario.
class AdminSession {
  final String token;
  final Establishment establishment;
  final String userName;
  final String email;

  const AdminSession({
    required this.token,
    required this.establishment,
    required this.userName,
    required this.email,
  });

  factory AdminSession.fromAuthResponse(Map<String, dynamic> json, {String? token}) => AdminSession(
        token: token ?? json['token'] as String,
        establishment: Establishment.fromJson(json['establishment']),
        userName: json['user']['name'] as String? ?? '',
        email: json['user']['email'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'establishment': establishment.toJson(),
        'user': {'name': userName, 'email': email},
      };
}

class AdminSessionStore {
  static const _key = 'admin_session_v1';

  static Future<AdminSession?> load() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      return raw == null ? null : AdminSession.fromAuthResponse(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(AdminSession session) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_key, jsonEncode(session.toJson()));
    } catch (_) {}
  }

  static Future<void> clear() async {
    try {
      await (await SharedPreferences.getInstance()).remove(_key);
    } catch (_) {}
  }
}
