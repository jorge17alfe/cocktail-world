import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../services/admin_session.dart';
import '../../widgets/public/async_state.dart';
import 'admin_families_page.dart';
import 'admin_login_page.dart';

/// Punto de entrada del modo admin: si hay sesión guardada y sigue válida entra directo, si no pide login.
class AdminGate extends StatefulWidget {
  const AdminGate({super.key});

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _error = null);
    final saved = await AdminSessionStore.load();
    if (!mounted) return;

    if (saved == null) {
      _replace(const AdminLoginPage());
      return;
    }

    try {
      final session = await AdminApiService().me(saved.token);
      await AdminSessionStore.save(session);
      if (mounted) _replace(AdminFamiliesPage(session: session));
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await AdminSessionStore.clear();
        if (mounted) _replace(const AdminLoginPage());
      } else if (mounted) {
        setState(() => _error = e);
      }
    }
  }

  void _replace(Widget page) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración')),
      body: _error == null ? const LoadingView() : ErrorView(error: _error!, onRetry: _check),
    );
  }
}
