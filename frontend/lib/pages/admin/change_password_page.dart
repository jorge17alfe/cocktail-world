import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../services/admin_session.dart';
import '../../widgets/admin/admin_ui.dart';

/// Cambiar la contraseña del administrador (p. ej. la temporal que le da Alocraise).
class ChangePasswordPage extends StatefulWidget {
  final AdminSession session;
  final AdminApiService? api;

  const ChangePasswordPage({super.key, required this.session, this.api});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late final AdminApiService _api = widget.api ?? AdminApiService.forSession(widget.session);
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _repeat = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_current, _new, _repeat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _api.changePassword(current: _current.text, newPassword: _new.text);
      if (!mounted) return;
      showSnack(context, 'Contraseña cambiada. Se han cerrado las sesiones en otros dispositivos.');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eye = IconButton(
      tooltip: _obscure ? 'Mostrar' : 'Ocultar',
      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
      onPressed: () => setState(() => _obscure = !_obscure),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(widget.session.email,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _current,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                        labelText: 'Contraseña actual', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: eye),
                    validator: (v) => (v == null || v.isEmpty) ? 'Obligatoria' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _new,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                      helperText: 'Mínimo 8 caracteres',
                      prefixIcon: Icon(Icons.lock_reset),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 8) return 'Mínimo 8 caracteres';
                      if (v == _current.text) return 'Tiene que ser distinta de la actual';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _repeat,
                    obscureText: _obscure,
                    decoration: const InputDecoration(
                        labelText: 'Repite la nueva contraseña', prefixIcon: Icon(Icons.lock_reset)),
                    validator: (v) => v != _new.text ? 'Las contraseñas no coinciden' : null,
                    onFieldSubmitted: (_) => _saving ? null : _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!, style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: _saving
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Cambiar contraseña', style: TextStyle(fontSize: 17)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
