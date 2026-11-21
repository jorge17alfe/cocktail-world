import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/deep_link.dart';
import 'package:frontend/pages/public/families_page.dart';
import 'package:frontend/pages/public/recipe_book_page.dart';
import 'package:frontend/pages/welcome_page.dart';
import 'package:frontend/services/public_api_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8'});

final _mojito = {
  'id': 1,
  'name': 'Mojito',
  'tags': ['Clásicos', 'Ron'],
  'images': [],
  'ingredients': [
    {'name': 'Ron blanco', 'amount': 50, 'unit': 'ml'},
  ],
  'steps': ['Macerar la hierbabuena'],
  'utensils': [],
};

PublicApiService _api({bool showBranding = true}) => PublicApiService(
  baseUrl: 'http://test/api/v1',
  client: MockClient((req) async {
    switch (req.url.path) {
      case '/api/v1/public/library':
        return _json({
          'data': [
            {'id': 1, 'name': 'Mojito', 'tags': ['Clásicos', 'Ron']},
            {'id': 2, 'name': 'Mai Tai', 'tags': ['Tiki', 'Ron']},
          ],
        });
      case '/api/v1/public/library/1':
        return _json({'data': _mojito});
      case '/api/v1/public/100001':
        return _json({
          'establishment': {'id': 1, 'code': '100001', 'name': 'Bar Pepe', 'show_branding': showBranding},
          'families': [
            {'id': 3, 'name': 'Clásicos', 'cocktails_count': 4},
          ],
        });
    }
    return _json({'message': 'no'}, 404);
  }),
);

Widget _app(Widget home) => MaterialApp(theme: AppTheme.light(), home: home);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('reconoce los enlaces del recetario', () {
    expect(parseRecetarioPath('/recetario'), (cocktailId: null));
    expect(parseRecetarioPath('/recetario/'), (cocktailId: null));
    expect(parseRecetarioPath('/recetario/c/12'), (cocktailId: 12));
    expect(parseRecetarioPath('/carta/100001'), isNull);
    expect(parseRecetarioPath('/recetario/abc'), isNull);
    expect(recetarioUrl('https://cocktail-world.alocraise.com', 12),
        'https://cocktail-world.alocraise.com/recetario/c/12');
  });

  testWidgets('la entrada tiene el enlace discreto al recetario', (tester) async {
    await tester.pumpWidget(_app(const WelcomePage()));
    expect(find.text('Recetario de cócteles'), findsOneWidget);
    // Sigue siendo secundario: no es un botón relleno ni con borde
    expect(
      find.ancestor(of: find.text('Recetario de cócteles'), matching: find.byWidgetPredicate((w) => w is TextButton)),
      findsOneWidget,
    );
  });

  testWidgets('recetario: filtra por grupo, busca y abre la ficha', (tester) async {
    await tester.pumpWidget(_app(RecipeBookPage(api: _api())));
    await tester.pumpAndSettle();

    expect(find.text('Mojito'), findsOneWidget);
    expect(find.text('Mai Tai'), findsOneWidget);
    expect(find.text('¿Tienes un bar?'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Tiki'));
    await tester.pumpAndSettle();
    expect(find.text('Mojito'), findsNothing);
    expect(find.text('Mai Tai'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Todos'));
    await tester.enterText(find.byType(TextField), 'mojito');
    await tester.pumpAndSettle();
    expect(find.text('Mai Tai'), findsNothing);

    await tester.tap(find.text('Mojito'));
    await tester.pumpAndSettle();
    expect(find.text('Ron blanco'), findsOneWidget);
    expect(find.text('50 ml'), findsOneWidget);
    expect(find.byTooltip('Copiar enlace'), findsOneWidget);
  });

  testWidgets('la carta del local lleva la firma al final y abre el recetario', (tester) async {
    await tester.pumpWidget(_app(FamiliesPage(code: '100001', api: _api())));
    await tester.pumpAndSettle();

    expect(find.text('Carta creada con Cocktail World'), findsOneWidget);
    await tester.tap(find.text('Ver recetario'));
    await tester.pumpAndSettle();
    expect(find.text('Recetario de cócteles'), findsOneWidget);
    expect(find.text('Mojito'), findsOneWidget);
  });

  testWidgets('un local sin firma no la muestra', (tester) async {
    await tester.pumpWidget(_app(FamiliesPage(code: '100001', api: _api(showBranding: false))));
    await tester.pumpAndSettle();

    expect(find.text('Clásicos'), findsOneWidget);
    expect(find.text('Carta creada con Cocktail World'), findsNothing);
  });
}
