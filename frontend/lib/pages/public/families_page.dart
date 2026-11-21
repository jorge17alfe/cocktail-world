import 'package:flutter/material.dart';

import '../../services/establishment_store.dart';
import '../../services/public_api_service.dart';
import '../../widgets/public/async_state.dart';
import '../../widgets/public/branding_footer.dart';
import '../../widgets/public/cards.dart';
import '../../widgets/public/offline_banner.dart';
import 'enter_code_page.dart';
import 'family_cocktails_page.dart';
import '../../widgets/public/centered_body.dart';

/// Familias del establecimiento: "Clásicos", "Internacionales"...
class FamiliesPage extends StatefulWidget {
  final String code;
  final PublicApiService api;
  final EstablishmentData? initial;

  const FamiliesPage({super.key, required this.code, required this.api, this.initial});

  @override
  State<FamiliesPage> createState() => _FamiliesPageState();
}

class _FamiliesPageState extends State<FamiliesPage> {
  EstablishmentData? _data;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _data = widget.initial;
    if (_data == null) _load();
  }

  /// Si se llegó por enlace no hay pantalla anterior: se abre la de introducir el número.
  void _changeEstablishment() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(MaterialPageRoute(builder: (_) => EnterCodePage(api: widget.api)));
    }
  }

  Future<void> _download() async {
    final progress = ValueNotifier<(int, int)>((0, 0));
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Guardando la carta'),
        content: ValueListenableBuilder(
          valueListenable: progress,
          builder: (_, p, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: p.$2 == 0 ? null : p.$1 / p.$2),
              const SizedBox(height: 12),
              Text(p.$2 == 0 ? 'Preparando…' : '${p.$1} de ${p.$2} cócteles'),
            ],
          ),
        ),
      ),
    );

    String message;
    try {
      final count = await widget.api.downloadAll(widget.code, onProgress: (d, t) => progress.value = (d, t));
      message = 'Listo: $count cócteles disponibles sin conexión';
      await _load();
    } on ApiException catch (e) {
      message = e.message;
    }
    navigator.pop();
    progress.dispose();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final data = await widget.api.getEstablishment(widget.code);
      await EstablishmentStore.save(widget.code, data.establishment.name);
      if (mounted) setState(() => _data = data);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Scaffold(
      appBar: AppBar(
        title: Text(data?.establishment.name ?? 'Carta'),
        actions: [
          PopupMenuButton<VoidCallback>(
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _download,
                child: const ListTile(
                  leading: Icon(Icons.download_for_offline_outlined),
                  title: Text('Guardar para usar sin conexión'),
                ),
              ),
              PopupMenuItem(
                value: _changeEstablishment,
                child: const ListTile(leading: Icon(Icons.storefront_outlined), title: Text('Cambiar de local')),
              ),
            ],
          ),
        ],
        bottom: data?.offlineSince == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: OfflineBanner(since: data!.offlineSince),
              ),
      ),
      body: CenteredBody(
        child: _error != null && data == null
            ? ErrorView(error: _error!, onRetry: _load)
            : data == null
            ? const LoadingView()
            : RefreshIndicator(
                onRefresh: _load,
                child: CustomScrollView(
                  slivers: [
                    if (data.families.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 120, bottom: 40),
                          child: EmptyView(icon: Icons.local_bar_outlined, message: 'Este local todavía no tiene cócteles'),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 280,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: data.families.length,
                          itemBuilder: (context, i) => FamilyCard(
                            family: data.families[i],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    FamilyCocktailsPage(code: widget.code, family: data.families[i], api: widget.api),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Firma discreta al final (más adelante un local podrá ocultarla con un plan de pago)
                    if (data.establishment.showBranding) SliverToBoxAdapter(child: BrandingFooter(api: widget.api)),
                  ],
                ),
              ),
      ),
    );
  }
}
