import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/cocktail_models.dart';
import 'package:frontend/pages/public/cocktail_detail_page.dart';
import 'package:frontend/pages/public/enter_code_page.dart';
import 'package:frontend/services/public_api_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _negroni = {
  'id': 7,
  'family_id': 1,
  'family_name': 'Clásicos',
  'name': 'Negroni',
  'images': [],
  'ingredients': [
    {'id': 1, 'name': 'Ginebra', 'amount': 30, 'unit': 'ml', 'note': null},
    {'id': 2, 'name': 'Campari', 'amount': 30.0, 'unit': 'ml', 'note': null},
    {'id': 3, 'name': 'Piel de naranja', 'amount': null, 'unit': null, 'note': 'para perfumar'},
  ],
  'steps': ['Remover con hielo 30 segundos', 'Colar sobre hielo nuevo'],
  'history': 'Florencia, hacia 1919.',
  'utensils': [
    {'id': 1, 'name': 'Vaso mezclador', 'description': 'Para remover', 'image_url': null, 'is_global': true},
  ],
  'glass': 'Old fashioned',
  'technique': 'stir',
  'ice': 'Bloque',
  'garnish': 'Naranja',
  'price': '12.50',
  'tags': ['Clásicos'],
  'is_published': true,
};

PublicApiService _fakeApi() => PublicApiService(
      baseUrl: 'http://test/api/v1',
      client: MockClient((req) async {
        final path = req.url.path;
        if (path == '/api/v1/public/100001') {
          return http.Response(
            jsonEncode({
              'establishment': {'id': 1, 'code': '100001', 'name': 'Bar Demo', 'logo_url': null},
              'families': [
                {'id': 1, 'name': 'Clásicos', 'image_url': null, 'order': 1, 'cocktails_count': 1},
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (path == '/api/v1/public/100001/cocktails/7') {
          return http.Response(jsonEncode({'success': true, 'data': _negroni}), 200,
              headers: {'content-type': 'application/json; charset=utf-8'});
        }
        return http.Response('{"message":"Not found"}', 404);
      }),
    );

Widget _app(Widget home) => MaterialApp(theme: AppTheme.light(), home: home);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Modelos', () {
    test('formatea cantidades y precios', () {
      final c = Cocktail.fromJson(_negroni);
      expect(c.ingredients[0].quantity, '30 ml');
      expect(c.ingredients[2].quantity, '');
      expect(const Ingredient(name: 'Lima', amount: 0.5, unit: 'unidad').quantity, '0,5 unidad');
      expect(c.price, 12.5);
      expect(formatPrice(c.price!), '12,50 €');
      expect(c.techniqueLabel, 'Removido');
    });
  });

  testWidgets('ficha del cóctel cambia entre los 4 botones', (tester) async {
    await tester.pumpWidget(_app(CocktailDetailPage(code: '100001', cocktailId: 7, api: _fakeApi())));
    await tester.pumpAndSettle();

    // Cabecera
    expect(find.text('Negroni'), findsWidgets);
    expect(find.text('12,50 €'), findsOneWidget);

    // Ingredientes (sección por defecto)
    expect(find.text('Campari'), findsOneWidget);
    expect(find.text('para perfumar'), findsOneWidget);

    Future<void> tap(String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await tap('Elaboración');
    expect(find.text('Remover con hielo 30 segundos'), findsOneWidget);
    expect(find.text('Campari'), findsNothing);

    await tap('Historia');
    expect(find.text('Florencia, hacia 1919.'), findsOneWidget);

    await tap('Utensilios');
    expect(find.text('Vaso mezclador'), findsOneWidget);
  });

  testWidgets('número de establecimiento incorrecto muestra error', (tester) async {
    await tester.pumpWidget(_app(EnterCodePage(api: _fakeApi())));
    await tester.enterText(find.byType(TextField), '999999');
    await tester.tap(find.text('Ver carta'));
    await tester.pumpAndSettle();

    expect(find.text('No existe ningún establecimiento con el número 999999'), findsOneWidget);
  });

  testWidgets('número correcto abre las familias', (tester) async {
    await tester.pumpWidget(_app(EnterCodePage(api: _fakeApi())));
    await tester.enterText(find.byType(TextField), '100001');
    await tester.tap(find.text('Ver carta'));
    await tester.pumpAndSettle();

    expect(find.text('Bar Demo'), findsOneWidget);
    expect(find.text('Clásicos'), findsOneWidget);
    expect(find.text('1 cóctel'), findsOneWidget);
  });
}
