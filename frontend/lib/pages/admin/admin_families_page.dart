import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';
import '../../services/admin_api_service.dart';
import '../../services/admin_session.dart';
import '../../services/public_api_service.dart';
import '../../widgets/admin/admin_ui.dart';
import '../../widgets/public/async_state.dart';
import '../../widgets/public/cards.dart';
import '../public/families_page.dart';
import 'admin_family_page.dart';
import 'family_form_dialog.dart';
import 'qr_page.dart';
import 'utensils_page.dart';
import '../../widgets/public/centered_body.dart';

enum _FamilyAction { edit, photo, delete }

/// Inicio del admin: familias del local con opciones de crear, editar, foto y borrar.
class AdminFamiliesPage extends StatefulWidget {
  final AdminSession session;

  const AdminFamiliesPage({super.key, required this.session});

  @override
  State<AdminFamiliesPage> createState() => _AdminFamiliesPageState();
}

class _AdminFamiliesPageState extends State<AdminFamiliesPage> {
  late final AdminApiService _api = AdminApiService.forSession(widget.session);
  List<Family>? _families;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final families = await _api.families();
      if (mounted) setState(() => _families = families);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _run(Future<void> Function() action, {String? success}) async {
    setState(() => _busy = true);
    try {
      await action();
      await _load();
      if (mounted && success != null) showSnack(context, success);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() async {
    final data = await showFamilyFormDialog(context);
    if (data == null) return;
    await _run(() => _api.createFamily(data.name, description: data.description), success: 'Familia creada');
  }

  Future<void> _onAction(Family family, _FamilyAction action) async {
    switch (action) {
      case _FamilyAction.edit:
        final data = await showFamilyFormDialog(context, family: family);
        if (data == null) return;
        await _run(
          () => _api.updateFamily(family.id, name: data.name, description: data.description),
          success: 'Familia actualizada',
        );

      case _FamilyAction.photo:
        final files = await PhotoPicker.pick(context, max: 1);
        if (files.isEmpty) return;
        await _run(() => _api.uploadFamilyImage(family.id, files.first), success: 'Foto actualizada');

      case _FamilyAction.delete:
        final count = family.cocktailsCount ?? 0;
        final ok = await confirmDialog(
          context,
          title: 'Eliminar "${family.name}"',
          message: count == 0
              ? 'Se eliminará la familia.'
              : 'Esta familia tiene $count ${count == 1 ? 'cóctel' : 'cócteles'}. Se eliminarán también, con sus fotos. No se puede deshacer.',
        );
        if (!ok) return;
        await _run(() => _api.deleteFamily(family.id, force: true), success: 'Familia eliminada');
    }
  }

  Future<void> _logout() async {
    final ok = await confirmDialog(
      context,
      title: 'Cerrar sesión',
      message: '¿Quieres salir del modo administrador?',
      confirmLabel: 'Salir',
      destructive: false,
    );
    if (!ok) return;
    await _api.logout();
    await AdminSessionStore.clear();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openPublic() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FamiliesPage(code: widget.session.establishment.code, api: PublicApiService()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final families = _families;
    final est = widget.session.establishment;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(est.name),
            Text('Nº ${est.code} · Administración', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(tooltip: 'Ver como cliente', icon: const Icon(Icons.visibility_outlined), onPressed: _openPublic),
          IconButton(
            tooltip: 'QR de la carta',
            icon: const Icon(Icons.qr_code_2),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => QrPage(establishment: widget.session.establishment))),
          ),
          PopupMenuButton<void>(
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => UtensilsPage(session: widget.session))),
                child: const ListTile(leading: Icon(Icons.blender_outlined), title: Text('Utensilios')),
              ),
              PopupMenuItem(
                onTap: _logout,
                child: const ListTile(leading: Icon(Icons.logout), title: Text('Cerrar sesión')),
              ),
            ],
          ),
        ],
        bottom: _busy ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator()) : null,
      ),
      floatingActionButton: families == null || families.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _busy ? null : _create,
              icon: const Icon(Icons.add),
              label: const Text('Nueva familia'),
            ),
      body: CenteredBody(
        child: _error != null && families == null
            ? ErrorView(error: _error!, onRetry: _load)
            : families == null
            ? const LoadingView()
            : families.isEmpty
            ? _EmptyFamilies(onCreate: _create)
            : RefreshIndicator(
                onRefresh: _load,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: families.length,
                  itemBuilder: (context, i) {
                    final family = families[i];
                    return FamilyCard(
                      family: family,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AdminFamilyPage(session: widget.session, family: family),
                          ),
                        );
                        _load();
                      },
                      trailing: PopupMenuButton<_FamilyAction>(
                        tooltip: 'Opciones',
                        onSelected: (a) => _onAction(family, a),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: _FamilyAction.edit,
                            child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Editar')),
                          ),
                          PopupMenuItem(
                            value: _FamilyAction.photo,
                            child: ListTile(leading: Icon(Icons.image_outlined), title: Text('Cambiar foto')),
                          ),
                          PopupMenuItem(
                            value: _FamilyAction.delete,
                            child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Eliminar')),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _EmptyFamilies extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyFamilies({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wine_bar_outlined, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Empieza creando una familia', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Por ejemplo "Clásicos" o "Internacionales". Dentro podrás crear tus cócteles o añadirlos desde la biblioteca.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('Crear familia')),
          ],
        ),
      ),
    );
  }
}
