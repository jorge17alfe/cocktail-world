import 'package:flutter/foundation.dart';

class ApiConfig {
  // Cambia el servidor sin tocar código:
  //   flutter run --dart-define=API_HOST=http://192.168.1.138:8000
  // Otras IPs usadas: 127.0.0.1 (local) · 192.168.1.138 (casa mamá) · 192.168.1.71 (hotel)
  static const String _hostOverride = String.fromEnvironment('API_HOST');
  static const String _devHost = 'http://192.168.1.31:8000'; // casa

  /// En web la app la sirve el propio Laravel, así que usa el mismo dominio desde el que se abrió
  /// (así las fotos cargan sin problemas de CORS). En móvil, la IP de desarrollo o API_HOST.
  static String get host {
    if (_hostOverride.isNotEmpty) return _hostOverride;
    if (kIsWeb) return Uri.base.origin;
    return _devHost;
  }

  /// API multi-establecimiento.
  static String get v1 => '$host/api/v1';

  static const int timeout = 30;
}
