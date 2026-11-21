import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/cocktail_models.dart';
import 'package:frontend/pages/admin/library_page.dart';
import 'package:frontend/services/admin_api_service.dart';
import 'package:frontend/services/admin_session.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _session = AdminSession(
  token: 't0ken',
  establishment: Establishment(id: 1, code: '100001', name: 'Bar Pepe'),
  userName: 'Admin',
  email: 'admin@bar.com',
);

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8'});

AdminApiService _api({bool supportFails = false}) => AdminApiService(
      token: 't0ken',
      baseUrl: 'http://test/api/v1',
      client: MockClient((req) async {
        switch (req.url.path) {
          case '/api/v1/admin/library':
            return _json({
              'data': [
                {'id': 1, 'name': 'Mojito', 'tags': ['Clásicos', 'Ron']},
              ],
            });
          case '/api/v1/admin/cocktails':
            return _json({'data': []});
          case '/api/v1/admin/support':
            return supportFails ? _json({'message': 'Error'}, 500) : _json({'data': {'email': 'soporte@alocraise.com'}});
        }
        return _json({'message': 'no encontrado'}, 404);
      }),
    );

Widget _app(AdminApiService api, Future<bool> Function(Uri) openUrl) => MaterialApp(
      theme: AppTheme.light(),
      home: LibraryPage(
        session: _session,
        family: const Family(id: 3, name: 'Clásicos'),
        api: api,
        openUrl: openUrl,
      ),
    );

void main() {
  testWidgets('"¿Echas de menos un cóctel?" abre un email con lo buscado y el local', (tester) async {
    Uri? opened;
    await tester.pumpWidget(_app(_api(), (uri) async {
      opened = uri;
      return true;
    }));
    await tester.pumpAndSettle();

    expect(find.text('Mojito'), findsOneWidget);
    expect(find.text('¿Echas de menos un cóctel?'), findsOneWidget);

    // Busca algo que no está: el aviso sigue visible y el email lo incluye
    await tester.enterText(find.byType(TextField), 'Pisco Sour');
    await tester.pumpAndSettle();
    expect(find.text('Ningún cóctel coincide'), findsOneWidget);
    await tester.tap(find.text('¿Echas de menos un cóctel?'));
    await tester.pumpAndSettle();

    expect(opened!.scheme, 'mailto');
    expect(opened!.path, 'soporte@alocraise.com');
    final raw = opened.toString();
    expect(raw, isNot(contains('+')));
    final body = Uri.decodeComponent(raw.split('body=').last);
    expect(body, contains('Pisco Sour'));
    expect(body, contains('Bar Pepe (nº 100001)'));
  });

  testWidgets('si no se puede leer el email de soporte, la biblioteca funciona sin el aviso', (tester) async {
    await tester.pumpWidget(_app(_api(supportFails: true), (_) async => true));
    await tester.pumpAndSettle();

    expect(find.text('Mojito'), findsOneWidget);
    expect(find.text('¿Echas de menos un cóctel?'), findsNothing);
  });
}
