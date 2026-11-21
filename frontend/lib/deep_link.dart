/// Enlaces de la carta web: /carta/{número} y /carta/{número}/c/{cóctel}
/// (son los que lleva el QR del local; en web la app arranca directamente ahí).
({String code, int? cocktailId})? parseCartaPath(String path) {
  final match = RegExp(r'^/carta/(\d{4,12})(?:/c/(\d+))?/?$').firstMatch(path);
  if (match == null) return null;
  final cocktail = match.group(2);
  return (code: match.group(1)!, cocktailId: cocktail == null ? null : int.parse(cocktail));
}

/// Enlaces del recetario público: /recetario y /recetario/c/{cóctel}.
/// Devuelve null si no es del recetario; si lo es, el id del cóctel (o null para el listado).
({int? cocktailId})? parseRecetarioPath(String path) {
  final match = RegExp(r'^/recetario(?:/c/(\d+))?/?$').firstMatch(path);
  if (match == null) return null;
  final cocktail = match.group(1);
  return (cocktailId: cocktail == null ? null : int.parse(cocktail));
}

/// Enlace para compartir un cóctel del recetario (WhatsApp, etc.).
String recetarioUrl(String host, int cocktailId) => '$host/recetario/c/$cocktailId';
