import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/cocktail_models.dart';
import 'package:frontend/pages/admin/admin_login_page.dart';
import 'package:frontend/pages/admin/cocktail_editor_page.dart';
import 'package:frontend/services/admin_api_service.dart';
import 'package:frontend/services/admin_session.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _base = 'http://test/api/v1';
const _utf8 = {'content-type': 'application/json; charset=utf-8'};

http.Response _json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status, headers: _utf8);

final _session = AdminSession(
  token: 't0ken',
  establishment: const Establishment(id: 1, code: '100001', name: 'Bar Demo'),
  userName: 'Admin',
  email: 'admin@demo.com',
);

final _authResponse = {
  'success': true,
  'token': 't0ken',
  'user': {'id': 1, 'name': 'Admin', 'email': 'admin@demo.com', 'role': 'admin'},
  'establishment': {'id': 1, 'code': '100001', 'name': 'Bar Demo', 'logo_url': null},
};

final _families = {
  'success': true,
  'data': [
    {'id': 1, 'name': 'Clásicos', 'image_url': null, 'order': 1, 'cocktails_count': 0},
  ],
};

final _utensils = {
  'success': true,
  'data': [
    {'id': 5, 'name': 'Coctelera', 'description': null, 'image_url': null, 'is_global': true},
  ],
};

Map<String, dynamic> _cocktailJson(int id, {List images = const []}) => {
      'id': id,
      'family_id': 1,
      'name': 'Negroni',
      'images': images,
      'ingredients': [],
      'steps': [],
      'utensils': [],
      'tags': [],
      'is_published': true,
    };

/// Abre [page] desde una pantalla inicial para que el pop() al guardar funcione como en la app.
Widget _launcher(Widget page) => MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => ApiClient.clientFactory = null);

  testWidgets('login: error con credenciales malas y entra al panel con las buenas', (tester) async {
    final requests = <http.Request>[];
    ApiClient.clientFactory = () => MockClient((req) async {
          requests.add(req);
          if (req.url.path.endsWith('/auth/login')) {
            final body = jsonDecode(req.body);
            return body['password'] == 'demo1234'
                ? _json(_authResponse)
                : _json({'success': false, 'message': 'Número de establecimiento, email o contraseña incorrectos'}, 422);
          }
          if (req.url.path.endsWith('/admin/families')) {
            expect(req.headers['Authorization'], 'Bearer t0ken');
            return _json(_families);
          }
          return _json({'message': 'no'}, 404);
        });

    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const AdminLoginPage()));
    await tester.enterText(find.widgetWithText(TextFormField, 'Nº de establecimiento'), '100001');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'admin@demo.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'mala');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Número de establecimiento, email o contraseña incorrectos'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'demo1234');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Nº 100001 · Administración'), findsOneWidget);
    expect(find.text('Clásicos'), findsOneWidget);
    expect((await AdminSessionStore.load())?.token, 't0ken');
    expect(jsonDecode(requests.first.body)['establishment_code'], '100001');
  });

  group('Editor de cóctel', () {
    setUp(() {
      // Pantalla alta para que el formulario completo esté construido
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize = const Size(1000, 5000);
      binding.platformDispatcher.views.first.devicePixelRatio = 1;
    });
    tearDown(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });

    testWidgets('crear: envía ficha completa y omite filas vacías', (tester) async {
      Map<String, dynamic>? sent;
      final api = AdminApiService(
        token: 't0ken',
        baseUrl: _base,
        client: MockClient((req) async {
          if (req.method == 'GET' && req.url.path.endsWith('/admin/families')) return _json(_families);
          if (req.method == 'GET' && req.url.path.endsWith('/admin/utensils')) return _json(_utensils);
          if (req.method == 'POST' && req.url.path.endsWith('/admin/cocktails')) {
            sent = jsonDecode(req.body);
            return _json({'success': true, 'data': _cocktailJson(99)}, 201);
          }
          return _json({'message': 'no'}, 404);
        }),
      );

      await tester.pumpWidget(_launcher(CocktailEditorPage(session: _session, familyId: 1, api: api)));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      // Sin nombre no deja guardar
      await tester.tap(find.text('Crear cóctel'));
      await tester.pumpAndSettle();
      expect(find.text('El nombre es obligatorio'), findsOneWidget);
      expect(sent, isNull);

      await tester.enterText(find.widgetWithText(TextFormField, 'Nombre del cóctel *'), 'Negroni');
      await tester.enterText(find.widgetWithText(TextFormField, 'Precio (opcional)'), '12,5');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingrediente 1'), 'Ginebra');
      await tester.enterText(find.widgetWithText(TextFormField, 'Cant.').first, '30');
      await tester.enterText(find.widgetWithText(TextFormField, 'Unidad').first, 'ml');
      await tester.enterText(find.widgetWithText(TextFormField, 'Paso 1'), 'Remover con hielo');
      await tester.enterText(find.widgetWithText(TextFormField, 'Origen, anécdotas, quién lo creó...'), 'Florencia');
      await tester.tap(find.widgetWithText(FilterChip, 'Coctelera'));
      await tester.pump();

      await tester.tap(find.text('Crear cóctel'));
      await tester.pumpAndSettle();

      expect(sent, isNotNull);
      expect(sent!['name'], 'Negroni');
      expect(sent!['family_id'], 1);
      expect(sent!['price'], 12.5);
      expect(sent!['ingredients'], [
        {'name': 'Ginebra', 'amount': 30.0, 'unit': 'ml', 'note': null},
      ]); // la 2ª fila vacía no se envía
      expect(sent!['steps'], ['Remover con hielo']);
      expect(sent!['history'], 'Florencia');
      expect(sent!['utensil_ids'], [5]);
      expect(find.text('abrir'), findsOneWidget); // ha vuelto atrás tras guardar
    });

    testWidgets('editar: quitar una foto la borra en el servidor', (tester) async {
      final calls = <String>[];
      final images = [
        {'id': 11, 'url': 'http://test/a.jpg'},
        {'id': 12, 'url': 'http://test/b.jpg'},
      ];
      final api = AdminApiService(
        token: 't0ken',
        baseUrl: _base,
        client: MockClient((req) async {
          calls.add('${req.method} ${req.url.path.replaceFirst('/api/v1', '')}');
          if (req.url.path.endsWith('/admin/families')) return _json(_families);
          if (req.url.path.endsWith('/admin/utensils')) return _json(_utensils);
          if (req.method == 'PUT' && req.url.path.endsWith('/admin/cocktails/7')) {
            return _json({'success': true, 'data': _cocktailJson(7, images: images)});
          }
          if (req.method == 'DELETE') {
            return _json({'success': true, 'data': [images[1]]});
          }
          return _json({'message': 'no'}, 404);
        }),
      );
      final existing = Cocktail.fromJson(_cocktailJson(7, images: images));

      await tester.pumpWidget(_launcher(CocktailEditorPage(session: _session, familyId: 1, existing: existing, api: api)));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Portada'), findsOneWidget);
      await tester.tap(find.byTooltip('Quitar foto').first);
      await tester.pump();
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(calls, containsAllInOrder(['PUT /admin/cocktails/7', 'DELETE /admin/cocktails/7/images/11']));
      expect(calls.where((c) => c.contains('/images/order')), isEmpty); // con 1 foto no hace falta ordenar
    });
  });
}
