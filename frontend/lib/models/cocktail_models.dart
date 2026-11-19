// Modelos de la API v1 (establecimientos, familias y fichas de cócteles).

double? _toDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}');

List<String> _stringList(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toList() : const [];

class Establishment {
  final int id;
  final String code;
  final String name;
  final String? logoUrl;

  /// Enlace de la carta web (el que lleva el QR).
  final String? publicUrl;

  const Establishment({required this.id, required this.code, required this.name, this.logoUrl, this.publicUrl});

  factory Establishment.fromJson(Map<String, dynamic> json) => Establishment(
        id: json['id'] as int,
        code: json['code'].toString(),
        name: json['name'] as String? ?? '',
        logoUrl: json['logo_url'] as String?,
        publicUrl: json['public_url'] as String?,
      );

  Map<String, dynamic> toJson() => {'id': id, 'code': code, 'name': name, 'logo_url': logoUrl, 'public_url': publicUrl};
}

class Family {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? cocktailsCount;

  const Family({required this.id, required this.name, this.description, this.imageUrl, this.cocktailsCount});

  factory Family.fromJson(Map<String, dynamic> json) => Family(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        cocktailsCount: json['cocktails_count'] as int?,
      );
}

/// Versión ligera para los listados.
class CocktailSummary {
  final int id;
  final int? familyId;
  final String name;
  final String? imageUrl;
  final double? price;
  final List<String> tags;
  final bool isPublished;
  final int? sourceCocktailId;

  const CocktailSummary({
    required this.id,
    required this.name,
    this.familyId,
    this.imageUrl,
    this.price,
    this.tags = const [],
    this.isPublished = true,
    this.sourceCocktailId,
  });

  factory CocktailSummary.fromJson(Map<String, dynamic> json) => CocktailSummary(
        id: json['id'] as int,
        familyId: json['family_id'] as int?,
        name: json['name'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        price: _toDouble(json['price']),
        tags: _stringList(json['tags']),
        isPublished: json['is_published'] as bool? ?? true,
        sourceCocktailId: json['source_cocktail_id'] as int?,
      );
}

class Ingredient {
  final String name;
  final double? amount;
  final String? unit;
  final String? note;

  const Ingredient({required this.name, this.amount, this.unit, this.note});

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] as String? ?? '',
        amount: _toDouble(json['amount']),
        unit: json['unit'] as String?,
        note: json['note'] as String?,
      );

  /// "50 ml", "0,5 unidad", "3 golpes" o "" si no hay cantidad.
  String get quantity => quantityFor(1);

  /// Cantidad para [servings] copas (multiplica la cantidad, la unidad no cambia).
  String quantityFor(int servings) {
    final parts = <String>[
      if (amount != null) formatAmount(amount! * servings),
      if (unit != null && unit!.isNotEmpty) unit!,
    ];
    return parts.join(' ');
  }

  static String formatAmount(double value) {
    final rounded = (value * 10).round() / 10; // como mucho 1 decimal
    if (rounded == rounded.roundToDouble()) return rounded.toInt().toString();
    return rounded.toString().replaceAll('.', ',');
  }
}

class Utensil {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  /// true = de la biblioteca (común a todos los locales, no editable).
  final bool isGlobal;

  const Utensil({required this.id, required this.name, this.description, this.imageUrl, this.isGlobal = false});

  factory Utensil.fromJson(Map<String, dynamic> json) => Utensil(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        isGlobal: json['is_global'] as bool? ?? false,
      );
}

class CocktailImage {
  final int id;
  final String url;

  const CocktailImage({required this.id, required this.url});

  factory CocktailImage.fromJson(Map<String, dynamic> json) =>
      CocktailImage(id: json['id'] as int, url: json['url'] as String);
}

/// Ficha completa del cóctel.
class Cocktail {
  final int id;
  final int? familyId;
  final String? familyName;
  final String name;
  final List<CocktailImage> images;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final String? history;
  final List<Utensil> utensils;
  final String? glass;
  final String? technique;
  final String? ice;
  final String? garnish;
  final double? price;
  final List<String> tags;
  final bool isPublished;

  const Cocktail({
    required this.id,
    required this.name,
    this.familyId,
    this.familyName,
    this.images = const [],
    this.ingredients = const [],
    this.steps = const [],
    this.history,
    this.utensils = const [],
    this.glass,
    this.technique,
    this.ice,
    this.garnish,
    this.price,
    this.tags = const [],
    this.isPublished = true,
  });

  factory Cocktail.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (json[key] as List? ?? []).map((e) => parse(e as Map<String, dynamic>)).toList();

    return Cocktail(
      id: json['id'] as int,
      familyId: json['family_id'] as int?,
      familyName: json['family_name'] as String?,
      name: json['name'] as String? ?? '',
      images: list('images', CocktailImage.fromJson),
      ingredients: list('ingredients', Ingredient.fromJson),
      steps: _stringList(json['steps']),
      history: json['history'] as String?,
      utensils: list('utensils', Utensil.fromJson),
      glass: json['glass'] as String?,
      technique: json['technique'] as String?,
      ice: json['ice'] as String?,
      garnish: json['garnish'] as String?,
      price: _toDouble(json['price']),
      tags: _stringList(json['tags']),
      isPublished: json['is_published'] as bool? ?? true,
    );
  }

  static const techniqueLabels = {
    'shake': 'Agitado',
    'stir': 'Removido',
    'build': 'Directo en vaso',
    'blend': 'Batido',
    'muddle': 'Macerado',
    'throw': 'Lanzado',
    'layer': 'En capas',
    'rolling': 'Rolling',
  };

  String? get techniqueLabel => technique == null ? null : (techniqueLabels[technique] ?? technique);
}

String formatPrice(double price) => '${price.toStringAsFixed(2).replaceAll('.', ',')} €';
