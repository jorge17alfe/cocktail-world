import 'package:shared_preferences/shared_preferences.dart';

/// Recuerda el último establecimiento consultado para no tener que teclear el número cada vez.
class EstablishmentStore {
  static const _codeKey = 'last_establishment_code';
  static const _nameKey = 'last_establishment_name';

  static Future<({String code, String name})?> getLast() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_codeKey);
      if (code == null) return null;
      return (code: code, name: prefs.getString(_nameKey) ?? code);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(String code, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_codeKey, code);
      await prefs.setString(_nameKey, name);
    } catch (_) {}
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_codeKey);
      await prefs.remove(_nameKey);
    } catch (_) {}
  }
}
