import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_navigator.dart';
import 'deep_link.dart';
import 'pages/public/cocktail_detail_page.dart';
import 'pages/public/families_page.dart';
import 'pages/admin/admin_login_page.dart';
import 'pages/welcome_page.dart';
import 'services/admin_session.dart';
import 'services/api_client.dart';
import 'services/public_api_service.dart';
import 'theme/app_theme.dart';

void main() {
  _handleExpiredSessions();
  runApp(const MyApp());
}

/// Si el servidor responde 401 (token caducado o revocado) se borra la sesión y se vuelve al login.
void _handleExpiredSessions() {
  var redirecting = false;
  ApiClient.onUnauthorized = () async {
    if (redirecting) return;
    redirecting = true;
    await AdminSessionStore.clear();
    final nav = appNavigatorKey.currentState;
    nav?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => route.isFirst,
    );
    final ctx = appNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Tu sesión ha caducado. Vuelve a iniciar sesión.'),
        ),
      );
    }
    redirecting = false;
  };
}

/// En web, si se abre desde el QR se entra directo: /carta/100001 → carta del local,
/// /carta/100001/c/16 → ficha del cóctel (con flecha para ir a la carta).
/// Es la pantalla inicial y no un push, porque en web el navegador hace un "atrás" al arrancar
/// que cerraría una pantalla abierta en ese momento.
Widget _initialPage() {
  final link = kIsWeb ? parseCartaPath(Uri.base.path) : null;
  if (link == null) return const WelcomePage();

  final api = PublicApiService();
  final cocktailId = link.cocktailId;
  if (cocktailId == null) return FamiliesPage(code: link.code, api: api);
  return CocktailDetailPage(code: link.code, cocktailId: cocktailId, api: api);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Cocktail World',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: _initialPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
