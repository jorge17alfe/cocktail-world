import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/cocktail_models.dart';
import 'package:frontend/pages/admin/qr_page.dart';
import 'package:frontend/pages/public/cocktail_detail_page.dart';
import 'package:frontend/pages/public/scan_qr_page.dart';
import 'package:frontend/services/public_api_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _utf8 = {'content-type': 'application/json; charset=utf-8'};

final _cocktail = {
  'id': 7,
  'family_id': 1,
  'name': 'Negroni',
  'images': [],
  'ingredients': [
    {'id': 1, 'name': 'Ginebra', 'amount': 30, 'unit': 'ml'},
    {'id': 2, 'name': 'Lima', 'amount': 0.5, 'unit': 'unidad'},
    {'id': 3, 'name': 'Soda', 'amount': null, 'unit': null, 'note': 'para completar'},
  ],
  'steps': ['Remover'],
  'utensils': [],
  'tags': [],
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('QR: reconoce la URL de la carta o el número', () {
    expect(ScanQrPage.codeFrom('http://192.168.1.31:8000/carta/100001'), '100001');
    expect(ScanQrPage.codeFrom('https://cocteles.es/carta/123456/c/7'), '123456');
    expect(ScanQrPage.codeFrom(' 100001 '), '100001');
    expect(ScanQrPage.codeFrom('https://otra-web.com/hola'), isNull);
    expect(ScanQrPage.codeFrom('12'), isNull);
    expect(ScanQrPage.codeFrom(null), isNull);
  });

  test('cantidades de una copa', () {
    expect(const Ingredient(name: 'Ginebra', amount: 30, unit: 'ml').quantity, '30 ml');
    expect(const Ingredient(name: 'Lima', amount: 0.5, unit: 'unidad').quantity, '0,5 unidad');
    expect(const Ingredient(name: 'Angostura', amount: 2, unit: 'golpes').quantity, '2 golpes');
    expect(const Ingredient(name: 'Soda').quantity, '');
  });

  group('Sin conexión', () {
    test('usa la última copia si no hay red y avisa de cuándo es', () async {
      var online = true;
      final api = PublicApiService(
        baseUrl: 'http://test/api/v1',
        client: MockClient((req) async {
          if (!online) throw http.ClientException('sin red');
          return http.Response(jsonEncode({'success': true, 'data': _cocktail}), 200, headers: _utf8);
        }),
      );

      final first = await api.getCocktail('100001', 7);
      expect(first.offlineSince, isNull);

      online = false;
      final cached = await api.getCocktail('100001', 7);
      expect(cached.cocktail.name, 'Negroni');
      expect(cached.offlineSince, isNotNull);

      // Algo que nunca se abrió: error normal
      expect(() => api.getCocktail('100001', 8), throwsA(isA<ApiException>()));
    });

    test('un 404 del servidor no se tapa con la copia', () async {
      var deleted = false;
      final api = PublicApiService(
        baseUrl: 'http://test/api/v1',
        client: MockClient((req) async => deleted
            ? http.Response('{"message":"No"}', 404)
            : http.Response(jsonEncode({'success': true, 'data': _cocktail}), 200, headers: _utf8)),
      );
      await api.getCocktail('100001', 7);
      deleted = true;
      expect(
        () => api.getCocktail('100001', 7),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 404)),
      );
    });
  });

  testWidgets('la ficha muestra las cantidades de una copa, sin multiplicador', (tester) async {
    final api = PublicApiService(
      baseUrl: 'http://test/api/v1',
      client: MockClient((_) async => http.Response(jsonEncode({'success': true, 'data': _cocktail}), 200, headers: _utf8)),
    );
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: CocktailDetailPage(code: '100001', cocktailId: 7, api: api),
    ));
    await tester.pumpAndSettle();

    expect(find.text('30 ml'), findsOneWidget);
    expect(find.text('0,5 unidad'), findsOneWidget);
    expect(find.text('para completar'), findsOneWidget);
    expect(find.text('×2'), findsNothing);
    expect(find.text('Copas'), findsNothing);
  });

  testWidgets('el QR lleva a la carta web del local', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const QrPage(
        establishment: Establishment(
            id: 1, code: '100001', name: 'Bar Demo', publicUrl: 'https://cocteles.es/carta/100001'),
      ),
    ));
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(find.text('https://cocteles.es/carta/100001'), findsOneWidget);
    expect(find.text('Dirección de pruebas'), findsNothing);
    expect(qr.semanticsLabel, contains('Bar Demo'));
  });
}
