import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/admin_api_service.dart';
import '../../services/admin_session.dart';
import '../../services/establishment_store.dart';
import 'admin_families_page.dart';

/// Alta de un establecimiento nuevo. El servidor genera el nº de establecimiento.
class AdminRegisterPage extends StatefulWidget {
  final AdminApiService api;

  const AdminRegisterPage({super.key, required this.api});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _establishment = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_establishment, _name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = await widget.api.register(
        establishmentName: _establishment.text.trim(),
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      await AdminSessionStore.save(session);
      await EstablishmentStore.save(session.establishment.code, session.establishment.name);
      if (!mounted) return;

      await _showCode(session.establishment.code);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AdminFamiliesPage(session: session)),
        (route) => route.isFirst,
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showCode(String code) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          icon: const Icon(Icons.celebration_outlined),
          title: const Text('¡Local creado!'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Tu número de establecimiento es:', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            SelectableText(code,
                style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold, letterSpacing: 6, color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            const Text(
              'Guárdalo: lo necesitas para entrar como administrador y es el que tus clientes y camareros usan para ver la carta.',
              textAlign: TextAlign.center,
            ),
          ]),
          actions: [
            TextButton.icon(
              onPressed: () => Clipboard.setData(ClipboardData(text: code)),
              icon: const Icon(Icons.copy),
              label: const Text('Copiar'),
            ),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido')),
          ],
        );
      },
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Alta de establecimiento')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _establishment,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'Nombre del local', prefixIcon: Icon(Icons.storefront_outlined)),
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Tu nombre', prefixIcon: Icon(Icons.person_outline)),
                      validator: _required,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Email no válido' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Contraseña', helperText: 'Mínimo 8 caracteres', prefixIcon: Icon(Icons.lock_outline)),
                      validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Repite la contraseña', prefixIcon: Icon(Icons.lock_outline)),
                      validator: (v) => v != _password.text ? 'Las contraseñas no coinciden' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(_error!, style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Crear local', style: TextStyle(fontSize: 17)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
