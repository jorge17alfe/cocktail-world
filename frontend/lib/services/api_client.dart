import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Archivo a subir (bytes + nombre), independiente de la plataforma.
class UploadFile {
  final Uint8List bytes;
  final String filename;

  const UploadFile(this.bytes, this.filename);
}

/// Cliente HTTP común de la API v1: cabeceras, token, timeout y errores en castellano.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl, this.token})
      : _client = client ?? clientFactory?.call() ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.v1;

  final http.Client _client;
  final String _baseUrl;
  String? token;

  /// Solo para tests: permite inyectar un cliente HTTP simulado en todas las pantallas.
  static http.Client Function()? clientFactory;

  /// Se llama cuando el servidor responde 401 (sesión caducada o cerrada).
  static void Function()? onUnauthorized;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> get(String path, {String? notFound}) =>
      _send(() => _client.get(_uri(path), headers: _headers), notFound: notFound);

  Future<Map<String, dynamic>> post(String path, [Object? body]) => _send(() => _client.post(_uri(path),
      headers: {..._headers, 'Content-Type': 'application/json'}, body: jsonEncode(body ?? {})));

  Future<Map<String, dynamic>> put(String path, Object body) => _send(() => _client.put(_uri(path),
      headers: {..._headers, 'Content-Type': 'application/json'}, body: jsonEncode(body)));

  Future<Map<String, dynamic>> delete(String path) =>
      _send(() => _client.delete(_uri(path), headers: _headers));

  /// POST multipart. [field] "images[]" para varias, "image" para una.
  Future<Map<String, dynamic>> upload(String path, String field, List<UploadFile> files) {
    return _send(() async {
      final request = http.MultipartRequest('POST', _uri(path))..headers.addAll(_headers);
      for (final f in files) {
        request.files.add(http.MultipartFile.fromBytes(field, f.bytes, filename: f.filename));
      }
      return http.Response.fromStream(await _client.send(request));
    }, timeout: const Duration(seconds: 120));
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request, {
    String? notFound,
    Duration timeout = const Duration(seconds: ApiConfig.timeout),
  }) async {
    final http.Response response;
    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      throw const ApiException('El servidor tarda demasiado en responder');
    } catch (_) {
      throw const ApiException('No se pudo conectar con el servidor. Revisa la conexión.');
    }

    Map<String, dynamic>? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }

    final status = response.statusCode;
    if (status >= 200 && status < 300 && body != null) return body;

    if (status == 401) {
      onUnauthorized?.call();
      throw const ApiException('Tu sesión ha caducado. Vuelve a iniciar sesión.', statusCode: 401);
    }
    if (status == 404) throw ApiException(notFound ?? 'No encontrado', statusCode: 404);
    if (status == 413) throw const ApiException('Las imágenes pesan demasiado', statusCode: 413);
    if (status == 429) throw const ApiException('Demasiadas peticiones, espera un momento', statusCode: 429);

    // 422 de Laravel: { message, errors: { campo: [mensajes] } } → primer mensaje concreto
    final errors = body?['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      throw ApiException(first is List && first.isNotEmpty ? '${first.first}' : '$first', statusCode: status);
    }
    throw ApiException(body?['message'] as String? ?? 'Error del servidor ($status)', statusCode: status);
  }
}
