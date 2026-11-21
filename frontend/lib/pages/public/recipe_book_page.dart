import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';
import '../../services/admin_api_service.dart';
import '../../services/public_api_service.dart';
import '../../utils/text_search.dart';
import '../../widgets/public/async_state.dart';
import '../../widgets/public/cards.dart';
import '../../widgets/public/centered_body.dart';
import '../../widgets/public/offline_banner.dart';
import '../admin/admin_register_page.dart';
import '../welcome_page.dart';
import 'recipe_detail_page.dart';

/// Recetario público: los cócteles clásicos de la biblioteca, para cualquiera y sin login.
class RecipeBookPage extends StatefulWidget {
  final PublicApiService api;

  const RecipeBookPage({super.key, required this.api});

  @override
  State<RecipeBookPage> createState() => _RecipeBookPageState();
}

class _RecipeBookPageState extends State<RecipeBookPage> {
  List<CocktailSummary>? _cocktails;
  DateTime? _offlineSince;
  Object? _error;
  String _query = '';
  String? _group;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final data = await widget.api.getRecipeBook();
      if (mounted) {
        setState(() {
          _cocktails = data.cocktails;
          _offlineSince = data.offlineSince;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// El primer tag de cada cóctel es su grupo ("Clásicos", "Internacionales"...).
  List<String> get _groups => {
    for (final c in _cocktails ?? <CocktailSummary>[])
      if (c.tags.isNotEmpty) c.tags.first,
  }.toList();

  List<CocktailSummary> get _visible {
    final q = normalizeForSearch(_query.trim());
    return (_cocktails ?? [])
        .where((c) => _group == null || (c.tags.isNotEmpty && c.tags.first == _group))
        .where(
          (c) =>
              q.isEmpty ||
              normalizeForSearch(c.name).contains(q) ||
              c.tags.any((t) => normalizeForSearch(t).contains(q)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = _cocktails;
    final visible = _visible;
    final groups = _groups;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetario de cócteles'),
        // Abierto desde un enlace compartido (no hay pantalla anterior): ir a la entrada de la app
        leading: Navigator.of(context).canPop()
            ? null
            : IconButton(
                tooltip: 'Inicio',
                icon: const Icon(Icons.home_outlined),
                onPressed: () => Navigator.of(
                  context,
                ).pushReplacement(MaterialPageRoute(builder: (_) => const WelcomePage())),
              ),
        bottom: _offlineSince == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: OfflineBanner(since: _offlineSince),
              ),
      ),
      body: CenteredBody(
        child: _error != null && all == null
            ? ErrorView(error: _error!, onRetry: _load)
            : all == null
            ? const LoadingView()
            : RefreshIndicator(
                onRefresh: _load,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Buscar por nombre o licor',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                    ),
                    if (groups.length > 1)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 52,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            children: [
                              ChoiceChip(
                                label: const Text('Todos'),
                                selected: _group == null,
                                onSelected: (_) => setState(() => _group = null),
                              ),
                              for (final g in groups)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: ChoiceChip(
                                    label: Text(g),
                                    selected: _group == g,
                                    onSelected: (_) => setState(() => _group = g),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (visible.isEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 240,
                          child: EmptyView(
                            icon: Icons.search_off,
                            message: all.isEmpty ? 'El recetario todavía está vacío' : 'Ningún cóctel coincide',
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 240,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: visible.length,
                          itemBuilder: (context, i) => CocktailCard(
                            cocktail: visible[i],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailPage(
                                  cocktailId: visible[i].id,
                                  api: widget.api,
                                  initialName: visible[i].name,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: _HaveABarCard()),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Al final del recetario: invitación para que los bares creen su carta.
class _HaveABarCard extends StatelessWidget {
  const _HaveABarCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(Icons.storefront_outlined, color: theme.colorScheme.primary),
          title: const Text('¿Tienes un bar?', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Crea la carta de cócteles de tu local, con QR para tus clientes'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminRegisterPage(api: AdminApiService()))),
        ),
      ),
    );
  }
}
