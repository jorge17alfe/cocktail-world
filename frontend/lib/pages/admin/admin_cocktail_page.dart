import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';
import '../../services/admin_api_service.dart';
import '../../services/admin_session.dart';
import '../../widgets/admin/admin_ui.dart';
import '../../widgets/public/async_state.dart';
import '../../widgets/public/cocktail_detail_view.dart';
import 'cocktail_editor_page.dart';

/// Ficha del cóctel en modo admin: igual que la pública + editar / eliminar.
class AdminCocktailPage extends StatefulWidget {
  final AdminSession session;
  final int cocktailId;

  const AdminCocktailPage({super.key, required this.session, required this.cocktailId});

  @override
  State<AdminCocktailPage> createState() => _AdminCocktailPageState();
}

class _AdminCocktailPageState extends State<AdminCocktailPage> {
  late final AdminApiService _api = AdminApiService.forSession(widget.session);
  Cocktail? _cocktail;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final c = await _api.cocktail(widget.cocktailId);
      if (mounted) setState(() => _cocktail = c);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _edit() async {
    final c = _cocktail!;
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => CocktailEditorPage(session: widget.session, familyId: c.familyId!, existing: c),
    ));
    if (saved == true) _load();
  }

  Future<void> _delete() async {
    final c = _cocktail!;
    final ok = await confirmDialog(context,
        title: 'Eliminar "${c.name}"', message: 'Se eliminará el cóctel y sus fotos. No se puede deshacer.');
    if (!ok) return;
    try {
      await _api.deleteCocktail(c.id);
      if (!mounted) return;
      showSnack(context, 'Cóctel eliminado');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _cocktail;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(c?.name ?? ''),
        actions: c == null
            ? null
            : [
                IconButton(tooltip: 'Editar', icon: const Icon(Icons.edit_outlined), onPressed: _edit),
                IconButton(tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline), onPressed: _delete),
              ],
      ),
      floatingActionButton: c == null
          ? null
          : FloatingActionButton.extended(onPressed: _edit, icon: const Icon(Icons.edit), label: const Text('Editar')),
      body: _error != null && c == null
          ? ErrorView(error: _error!, onRetry: _load)
          : c == null
              ? const LoadingView()
              : CocktailDetailView(
                  cocktail: c,
                  banner: c.isPublished
                      ? null
                      : MaterialBanner(
                          backgroundColor: scheme.tertiaryContainer,
                          leading: const Icon(Icons.visibility_off),
                          content: const Text('Oculto: los clientes y camareros no lo ven.'),
                          actions: [TextButton(onPressed: _edit, child: const Text('Editar'))],
                        ),
                ),
    );
  }
}
