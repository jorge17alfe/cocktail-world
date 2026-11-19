import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';
import '../../services/admin_api_service.dart';
import '../../services/admin_session.dart';
import '../../widgets/public/async_state.dart';
import '../../widgets/public/cards.dart';
import 'admin_cocktail_page.dart';
import 'cocktail_editor_page.dart';
import 'library_page.dart';
import '../../widgets/public/centered_body.dart';

/// Cócteles de una familia (incluye los no publicados) + crear nuevo / añadir desde biblioteca.
class AdminFamilyPage extends StatefulWidget {
  final AdminSession session;
  final Family family;

  const AdminFamilyPage({super.key, required this.session, required this.family});

  @override
  State<AdminFamilyPage> createState() => _AdminFamilyPageState();
}

class _AdminFamilyPageState extends State<AdminFamilyPage> {
  late final AdminApiService _api = AdminApiService.forSession(widget.session);
  List<CocktailSummary>? _cocktails;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final cocktails = await _api.cocktails(familyId: widget.family.id);
      if (mounted) setState(() => _cocktails = cocktails);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _push(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    _load();
  }

  void _newCocktail() => _push(CocktailEditorPage(session: widget.session, familyId: widget.family.id));

  void _fromLibrary() => _push(LibraryPage(session: widget.session, family: widget.family));

  @override
  Widget build(BuildContext context) {
    final cocktails = _cocktails;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.family.name),
        actions: [
          IconButton(
            tooltip: 'Añadir desde la biblioteca',
            icon: const Icon(Icons.library_add_outlined),
            onPressed: _fromLibrary,
          ),
        ],
      ),
      floatingActionButton: cocktails == null || cocktails.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _newCocktail,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo cóctel'),
            ),
      body: CenteredBody(
        child: _error != null && cocktails == null
            ? ErrorView(error: _error!, onRetry: _load)
            : cocktails == null
            ? const LoadingView()
            : cocktails.isEmpty
            ? _EmptyFamily(onCreate: _newCocktail, onLibrary: _fromLibrary)
            : RefreshIndicator(
                onRefresh: _load,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: cocktails.length,
                  itemBuilder: (context, i) {
                    final c = cocktails[i];
                    return CocktailCard(
                      cocktail: c,
                      badge: c.isPublished ? null : const CardBadge('Oculto', icon: Icons.visibility_off),
                      onTap: () => _push(AdminCocktailPage(session: widget.session, cocktailId: c.id)),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _EmptyFamily extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onLibrary;

  const _EmptyFamily({required this.onCreate, required this.onLibrary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_bar_outlined, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Esta familia está vacía', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('Crear cóctel')),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onLibrary,
              icon: const Icon(Icons.library_add_outlined),
              label: const Text('Añadir desde la biblioteca'),
            ),
          ],
        ),
      ),
    );
  }
}
