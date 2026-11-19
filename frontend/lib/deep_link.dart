/// Enlaces de la carta web: /carta/{número} y /carta/{número}/c/{cóctel}
/// (son los que lleva el QR del local; en web la app arranca directamente ahí).
({String code, int? cocktailId})? parseCartaPath(String path) {
  final match = RegExp(r'^/carta/(\d{4,12})(?:/c/(\d+))?/?$').firstMatch(path);
  if (match == null) return null;
  final cocktail = match.group(2);
  return (code: match.group(1)!, cocktailId: cocktail == null ? null : int.parse(cocktail));
}
