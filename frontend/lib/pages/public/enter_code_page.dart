import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/establishment_store.dart';
import '../../services/public_api_service.dart';
import '../../widgets/images/icons/app_icon.dart';
import 'families_page.dart';
import 'scan_qr_page.dart';

/// Entrada a la carta pública: se teclea el número de establecimiento.
class EnterCodePage extends StatefulWidget {
  final PublicApiService? api;

  const EnterCodePage({super.key, this.api});

  @override
  State<EnterCodePage> createState() => _EnterCodePageState();
}

class _EnterCodePageState extends State<EnterCodePage> {
  late final PublicApiService _api = widget.api ?? PublicApiService();
  final _controller = TextEditingController();
  ({String code, String name})? _last;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    EstablishmentStore.getLast().then((last) {
      if (mounted) setState(() => _last = last);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open(String code) async {
    code = code.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Escribe el número de establecimiento');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getEstablishment(code);
      await EstablishmentStore.save(code, result.establishment.name);
      if (!mounted) return;
      setState(() => _last = (code: code, name: result.establishment.name));
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => FamiliesPage(code: code, api: _api, initial: result),
      ));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _scan() async {
    final code = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const ScanQrPage()));
    if (code == null || !mounted) return;
    _controller.text = code;
    await _open(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppIcon(width: 120, height: 120, borderRadius: 28)),
                  const SizedBox(height: 24),
                  Text('Carta de cócteles',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Introduce el número de establecimiento',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 6),
                    decoration: InputDecoration(
                      hintText: '000000',
                      errorText: _error,
                      prefixIcon: const Icon(Icons.storefront_outlined),
                    ),
                    onSubmitted: _loading ? null : _open,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loading ? null : () => _open(_controller.text),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    icon: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.local_bar),
                    label: const Text('Ver carta', style: TextStyle(fontSize: 17)),
                  ),
                  if (ScanQrPage.isSupported) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _scan,
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Escanear QR', style: TextStyle(fontSize: 17)),
                    ),
                  ],
                  if (_last != null) ...[
                    const SizedBox(height: 28),
                    Text('Último consultado', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(_last!.name),
                        subtitle: Text('Nº ${_last!.code}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _loading ? null : () => _open(_last!.code),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
