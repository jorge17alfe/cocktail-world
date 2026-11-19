import 'package:http/http.dart' as http;

import '../models/cocktail_models.dart';
import 'admin_session.dart';
import 'api_client.dart';

export 'api_client.dart' show ApiException, UploadFile;

/// Datos que se envían al crear / editar un cóctel.
class CocktailInput {
  final int familyId;
  final String name;
  final double? price;
  final bool isPublished;
  final String? glass;
  final String? technique;
  final String? ice;
  final String? garnish;
  final String? history;
  final List<String> steps;
  final List<Ingredient> ingredients;
  final List<int> utensilIds;

  const CocktailInput({
    required this.familyId,
    required this.name,
    this.price,
    this.isPublished = true,
    this.glass,
    this.technique,
    this.ice,
    this.garnish,
    this.history,
    this.steps = const [],
    this.ingredients = const [],
    this.utensilIds = const [],
  });

  Map<String, dynamic> toJson() => {
        'family_id': familyId,
        'name': name,
        'price': price,
        'is_published': isPublished,
        'glass': glass,
        'technique': technique,
        'ice': ice,
        'garnish': garnish,
        'history': history,
        'steps': steps,
        'ingredients': [
          for (final i in ingredients) {'name': i.name, 'amount': i.amount, 'unit': i.unit, 'note': i.note},
        ],
        'utensil_ids': utensilIds,
      };
}

/// Llamadas del panel de administración (requieren token).
class AdminApiService {
  AdminApiService({String? token, http.Client? client, String? baseUrl})
      : _api = ApiClient(client: client, baseUrl: baseUrl, token: token);

  AdminApiService.forSession(AdminSession session, {http.Client? client, String? baseUrl})
      : this(token: session.token, client: client, baseUrl: baseUrl);

  final ApiClient _api;

  // ---- Auth ----
  Future<AdminSession> login(String code, String email, String password) async {
    final json = await _api.post('/auth/login', {
      'establishment_code': code,
      'email': email,
      'password': password,
      'device_name': 'app',
    });
    return AdminSession.fromAuthResponse(json);
  }

  Future<AdminSession> register({
    required String establishmentName,
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _api.post('/auth/register', {
      'establishment_name': establishmentName,
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'device_name': 'app',
    });
    return AdminSession.fromAuthResponse(json);
  }

  /// Comprueba que el token sigue siendo válido y devuelve la sesión actualizada.
  Future<AdminSession> me(String token) async {
    _api.token = token;
    return AdminSession.fromAuthResponse(await _api.get('/auth/me'), token: token);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
  }

  // ---- Familias ----
  Future<List<Family>> families() async =>
      _list(await _api.get('/admin/families'), Family.fromJson);

  Future<Family> createFamily(String name, {String? description}) async => Family.fromJson(
      (await _api.post('/admin/families', {'name': name, 'description': description}))['data']);

  Future<Family> updateFamily(int id, {required String name, String? description}) async => Family.fromJson(
      (await _api.put('/admin/families/$id', {'name': name, 'description': description}))['data']);

  /// Si la familia tiene cócteles y [force] es false lanza ApiException con statusCode 409.
  Future<void> deleteFamily(int id, {bool force = false}) =>
      _api.delete('/admin/families/$id${force ? '?force=1' : ''}');

  Future<Family> uploadFamilyImage(int id, UploadFile file) async =>
      Family.fromJson((await _api.upload('/admin/families/$id/image', 'image', [file]))['data']);

  // ---- Cócteles ----
  Future<List<CocktailSummary>> cocktails({int? familyId}) async => _list(
      await _api.get('/admin/cocktails${familyId != null ? '?family_id=$familyId' : ''}'),
      CocktailSummary.fromJson);

  Future<Cocktail> cocktail(int id) async =>
      Cocktail.fromJson((await _api.get('/admin/cocktails/$id', notFound: 'Este cóctel ya no existe'))['data']);

  Future<Cocktail> createCocktail(CocktailInput input) async =>
      Cocktail.fromJson((await _api.post('/admin/cocktails', input.toJson()))['data']);

  Future<Cocktail> updateCocktail(int id, CocktailInput input) async =>
      Cocktail.fromJson((await _api.put('/admin/cocktails/$id', input.toJson()))['data']);

  Future<void> deleteCocktail(int id) => _api.delete('/admin/cocktails/$id');

  // ---- Fotos del carrusel ----
  Future<List<CocktailImage>> uploadCocktailImages(int cocktailId, List<UploadFile> files) async =>
      _list(await _api.upload('/admin/cocktails/$cocktailId/images', 'images[]', files), CocktailImage.fromJson);

  Future<List<CocktailImage>> deleteCocktailImage(int cocktailId, int imageId) async =>
      _list(await _api.delete('/admin/cocktails/$cocktailId/images/$imageId'), CocktailImage.fromJson);

  Future<List<CocktailImage>> reorderCocktailImages(int cocktailId, List<int> ids) async =>
      _list(await _api.put('/admin/cocktails/$cocktailId/images/order', {'ids': ids}), CocktailImage.fromJson);

  // ---- Utensilios ----
  Future<List<Utensil>> utensils() async => _list(await _api.get('/admin/utensils'), Utensil.fromJson);

  Future<Utensil> createUtensil(String name, {String? description}) async => Utensil.fromJson(
      (await _api.post('/admin/utensils', {'name': name, 'description': description}))['data']);

  Future<Utensil> updateUtensil(int id, {required String name, String? description}) async => Utensil.fromJson(
      (await _api.put('/admin/utensils/$id', {'name': name, 'description': description}))['data']);

  Future<void> deleteUtensil(int id) => _api.delete('/admin/utensils/$id');

  /// Copia propia de un utensilio de la biblioteca (para ponerle foto); sustituye al global en tus cócteles.
  Future<Utensil> adoptUtensil(int id) async =>
      Utensil.fromJson((await _api.post('/admin/utensils/$id/adopt'))['data']);

  Future<Utensil> uploadUtensilImage(int id, UploadFile file) async =>
      Utensil.fromJson((await _api.upload('/admin/utensils/$id/image', 'image', [file]))['data']);

  // ---- Biblioteca ----
  Future<List<CocktailSummary>> library() async =>
      _list(await _api.get('/admin/library'), CocktailSummary.fromJson);

  Future<Cocktail> libraryCocktail(int id) async =>
      Cocktail.fromJson((await _api.get('/admin/library/$id'))['data']);

  Future<int> copyFromLibrary(int familyId, List<int> cocktailIds) async {
    final json = await _api.post('/admin/library/copy', {'family_id': familyId, 'cocktail_ids': cocktailIds});
    return (json['data'] as List).length;
  }

  List<T> _list<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) parse) =>
      (json['data'] as List).map((e) => parse(e as Map<String, dynamic>)).toList();
}
