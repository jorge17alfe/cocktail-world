import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/cocktail_models.dart';
import 'package:frontend/pages/admin/change_password_page.dart';
import 'package:frontend/services/admin_api_service.dart';
import 'package:frontend/services/admin_session.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _session = AdminSession(
  token: 't0ken',
  establishment: Establishment(id: 1, code: '100001', name: 'Bar'),
  userName: 'Admin',
  email: 'admin@bar.com',
);

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  testWidgets('cambiar contraseña: error con la actual mala y éxito con la buena', (tester) async {
    Map<String, dynamic>? sent;
    final api = AdminApiService(
      token: 't0ken',
      baseUrl: 'http://test/api/v1',
      client: MockClient((req) async {
        expect(req.method, 'PUT');
        expect(req.url.path, '/api/v1/auth/password');
        sent = jsonDecode(req.body);
        return sent!['current_password'] == 'temporal-123'
            ? _json({'success': true})
            : _json({
                'message': 'La contraseña actual no es correcta',
                'errors': {
                  'current_password': ['La contraseña actual no es correcta']
                },
              }, 422);
      }),
    );

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChangePasswordPage(session: _session, api: api))),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    // Validación local: no coinciden
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña actual'), 'mala');
    await tester.enterText(find.widgetWithText(TextFormField, 'Nueva contraseña'), 'nuevaclave1');
    await tester.enterText(find.widgetWithText(TextFormField, 'Repite la nueva contraseña'), 'otra');
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pumpAndSettle();
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(sent, isNull);

    // Contraseña actual incorrecta: mensaje del servidor
    await tester.enterText(find.widgetWithText(TextFormField, 'Repite la nueva contraseña'), 'nuevaclave1');
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pumpAndSettle();
    expect(find.text('La contraseña actual no es correcta'), findsOneWidget);

    // Correcta: vuelve atrás
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña actual'), 'temporal-123');
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar contraseña'));
    await tester.pumpAndSettle();
    expect(sent!['password'], 'nuevaclave1');
    expect(sent!['password_confirmation'], 'nuevaclave1');
    expect(find.text('abrir'), findsOneWidget);
  });
}
