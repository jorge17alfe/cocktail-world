import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';
import '../../services/admin_api_service.dart';
import '../../services/admin_session.dart';
import '../../widgets/admin/admin_ui.dart';
import '../../widgets/public/app_network_image.dart';
import '../../widgets/public/async_state.dart';
import '../../widgets/public/centered_body.dart';

enum _UtensilAction { photo, edit, delete }

/// Catálogo de utensilios del local: los propios (editables, con foto) y los de la biblioteca,
/// que se pueden "personalizar" para ponerles foto propia.
class UtensilsPage extends StatefulWidget {
  final AdminSession session;
  final AdminApiService? api;

  const UtensilsPage({super.key, required this.session, this.api});

  @override
  State<UtensilsPage> createState() => _UtensilsPageState();
}

class _UtensilsPageState extends State<UtensilsPage> {
  late final AdminApiService _api = widget.api ?? AdminApiService.forSession(widget.session);
  List<Utensil>? _utensils;
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
      final list = await _api.utensils();
      if (mounted) setState(() => _utensils = list);
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

  Future<({String name, String? description})?> _form({Utensil? utensil}) {
    final name = TextEditingController(text: utensil?.name);
    final description = TextEditingController(text: utensil?.description);
    return showDialog<({String name, String? description})>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(utensil == null ? 'Nuevo utensilio' : 'Editar utensilio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: description,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              final d = description.text.trim();
              Navigator.pop(ctx, (name: name.text.trim(), description: d.isEmpty ? null : d));
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ).whenComplete(() {
      name.dispose();
      description.dispose();
    });
  }

  Future<void> _create() async {
    final data = await _form();
    if (data == null) return;
    await _run(() => _api.createUtensil(data.name, description: data.description), success: 'Utensilio creado');
  }

  Future<void> _changePhoto(Utensil u) async {
    final files = await PhotoPicker.pick(context, max: 1);
    if (files.isEmpty) return;
    await _run(() => _api.uploadUtensilImage(u.id, files.first), success: 'Foto actualizada');
  }

  /// Utensilio de la biblioteca → copia propia (sustituye al global en tus cócteles) y le pone foto.
  Future<void> _personalize(Utensil global) async {
    final ok = await confirmDialog(
      context,
      title: 'Personalizar "${global.name}"',
      message:
          'Se creará tu propia versión de este utensilio para que le pongas foto o cambies el nombre. '
          'Tus cócteles que lo usan pasarán a usar tu versión.',
      confirmLabel: 'Personalizar',
      destructive: false,
    );
    if (!ok || !mounted) return;

    Utensil? own;
    await _run(() async => own = await _api.adoptUtensil(global.id));
    if (own != null && mounted) await _changePhoto(own!);
  }

  Future<void> _onAction(Utensil u, _UtensilAction action) async {
    switch (action) {
      case _UtensilAction.photo:
        await _changePhoto(u);
      case _UtensilAction.edit:
        final data = await _form(utensil: u);
        if (data == null) return;
        await _run(
          () => _api.updateUtensil(u.id, name: data.name, description: data.description),
          success: 'Utensilio actualizado',
        );
      case _UtensilAction.delete:
        final ok = await confirmDialog(
          context,
          title: 'Eliminar "${u.name}"',
          message: 'Se quitará de todos los cócteles que lo usan.',
        );
        if (!ok) return;
        await _run(() => _api.deleteUtensil(u.id), success: 'Utensilio eliminado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _utensils;
    final own = list?.where((u) => !u.isGlobal).toList() ?? [];
    final global = list?.where((u) => u.isGlobal).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utensilios'),
        bottom: _busy ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator()) : null,
      ),
      floatingActionButton: list == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _busy ? null : _create,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo utensilio'),
            ),
      body: CenteredBody(
        maxWidth: 760,
        child: _error != null && list == null
            ? ErrorView(error: _error!, onRetry: _load)
            : list == null
            ? const LoadingView()
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    _header(context, 'Tus utensilios', own.isEmpty ? 'Aún no tienes utensilios propios' : null),
                    for (final u in own)
                      _UtensilTile(
                        utensil: u,
                        onTap: () => _changePhoto(u),
                        trailing: PopupMenuButton<_UtensilAction>(
                          onSelected: (a) => _onAction(u, a),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: _UtensilAction.photo,
                              child: ListTile(leading: Icon(Icons.image_outlined), title: Text('Cambiar foto')),
                            ),
                            PopupMenuItem(
                              value: _UtensilAction.edit,
                              child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Editar')),
                            ),
                            PopupMenuItem(
                              value: _UtensilAction.delete,
                              child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Eliminar')),
                            ),
                          ],
                        ),
                      ),
                    _header(
                      context,
                      'De la biblioteca',
                      'Comunes a todos los locales. Personalízalos para ponerles tu foto.',
                    ),
                    for (final u in global)
                      _UtensilTile(
                        utensil: u,
                        onTap: () => _personalize(u),
                        trailing: TextButton(onPressed: () => _personalize(u), child: const Text('Personalizar')),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _header(BuildContext context, String title, String? subtitle) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (subtitle != null)
            Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _UtensilTile extends StatelessWidget {
  final Utensil utensil;
  final VoidCallback onTap;
  final Widget trailing;

  const _UtensilTile({required this.utensil, required this.onTap, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 52,
          height: 52,
          child: AppNetworkImage(url: utensil.imageUrl, placeholderIcon: Icons.add_a_photo_outlined),
        ),
      ),
      title: Text(utensil.name),
      subtitle: utensil.description == null
          ? null
          : Text(utensil.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: trailing,
    );
  }
}
