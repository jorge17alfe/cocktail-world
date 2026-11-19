import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/admin_api_service.dart';
import '../../services/admin_session.dart';
import '../../services/establishment_store.dart';
import '../../widgets/images/icons/app_icon.dart';
import 'admin_families_page.dart';
import 'admin_register_page.dart';

/// Login del administrador: número de establecimiento + email + contraseña.
class AdminLoginPage extends StatefulWidget {
  final AdminApiService? api;

  const AdminLoginPage({super.key, this.api});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  late final AdminApiService _api = widget.api ?? AdminApiService();
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    EstablishmentStore.getLast().then((last) {
      if (last != null && mounted && _code.text.isEmpty) _code.text = last.code;
    });
  }

  @override
  void dispose() {
    _code.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = await _api.login(_code.text.trim(), _email.text.trim(), _password.text);
      await AdminSessionStore.save(session);
      await EstablishmentStore.save(session.establishment.code, session.establishment.name);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Acceso administrador')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: AppIcon(width: 96, height: 96, borderRadius: 24)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _code,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
                        decoration: const InputDecoration(
                          labelText: 'Nº de establecimiento',
                          prefixIcon: Icon(Icons.storefront_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Email no válido' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
                        onFieldSubmitted: (_) => _loading ? null : _submit(),
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
                            : const Text('Entrar', style: TextStyle(fontSize: 17)),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => AdminRegisterPage(api: _api))),
                        child: const Text('¿Tienes un local nuevo? Darlo de alta'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
