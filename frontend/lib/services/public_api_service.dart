import 'package:http/http.dart' as http;

import '../models/cocktail_models.dart';
import 'api_client.dart';
import 'offline_cache.dart';

export 'api_client.dart' show ApiException;

typedef EstablishmentData = ({Establishment establishment, List<Family> families, DateTime? offlineSince});
typedef FamilyData = ({Family family, List<CocktailSummary> cocktails, DateTime? offlineSince});
typedef CocktailData = ({Cocktail cocktail, DateTime? offlineSince});

/// Vista pública (clientes y camareros): no necesita login.
/// Cada respuesta se guarda en el móvil; si no hay conexión se usa la última copia
/// y [offlineSince] indica de cuándo es.
class PublicApiService {
  PublicApiService({http.Client? client, String? baseUrl}) : _api = ApiClient(client: client, baseUrl: baseUrl);

  final ApiClient _api;

  Future<EstablishmentData> getEstablishment(String code) async {
    final (json, since) = await _get('/public/${Uri.encodeComponent(code)}',
        notFound: 'No existe ningún establecimiento con el número $code');

    return (
      establishment: Establishment.fromJson(json['establishment']),
      families: (json['families'] as List).map((f) => Family.fromJson(f)).toList(),
      offlineSince: since,
    );
  }

  Future<FamilyData> getFamily(String code, int familyId) async {
    final (json, since) = await _get('/public/${Uri.encodeComponent(code)}/families/$familyId',
        notFound: 'Esta familia ya no existe');

    return (
      family: Family.fromJson(json['family']),
      cocktails: (json['cocktails'] as List).map((c) => CocktailSummary.fromJson(c)).toList(),
      offlineSince: since,
    );
  }

  Future<CocktailData> getCocktail(String code, int cocktailId) async {
    final (json, since) = await _get('/public/${Uri.encodeComponent(code)}/cocktails/$cocktailId',
        notFound: 'Este cóctel ya no está disponible');

    return (cocktail: Cocktail.fromJson(json['data']), offlineSince: since);
  }

  /// Recetario público: todos los clásicos de la biblioteca.
  Future<({List<CocktailSummary> cocktails, DateTime? offlineSince})> getRecipeBook() async {
    final (json, since) = await _get('/public/library', notFound: 'El recetario no está disponible');

    return (
      cocktails: (json['data'] as List).map((c) => CocktailSummary.fromJson(c)).toList(),
      offlineSince: since,
    );
  }

  Future<CocktailData> getRecipe(int cocktailId) async {
    final (json, since) = await _get('/public/library/$cocktailId',
        notFound: 'Este cóctel ya no está en el recetario');

    return (cocktail: Cocktail.fromJson(json['data']), offlineSince: since);
  }

  /// Descarga la carta entera (familias + todas las fichas) para tenerla sin conexión.
  /// Devuelve cuántos cócteles se han guardado.
  Future<int> downloadAll(String code, {void Function(int done, int total)? onProgress}) async {
    final est = await getEstablishment(code);
    if (est.offlineSince != null) throw const ApiException('Necesitas conexión para descargar la carta');

    final families = <FamilyData>[];
    for (final f in est.families) {
      families.add(await getFamily(code, f.id));
    }

    final ids = [for (final f in families) ...f.cocktails.map((c) => c.id)];
    for (final (i, id) in ids.indexed) {
      onProgress?.call(i, ids.length);
      await getCocktail(code, id);
    }
    onProgress?.call(ids.length, ids.length);
    return ids.length;
  }

  Future<(Map<String, dynamic>, DateTime?)> _get(String path, {required String notFound}) async {
    try {
      final json = await _api.get(path, notFound: notFound);
      await OfflineCache.save(path, json);
      return (json, null);
    } on ApiException catch (e) {
      // Solo se usa la copia si el fallo es de conexión (no si el servidor dice 404, etc.)
      if (e.statusCode != null) rethrow;
      final cached = await OfflineCache.read(path);
      if (cached == null) rethrow;
      return (cached.body, cached.savedAt);
    }
  }
}
