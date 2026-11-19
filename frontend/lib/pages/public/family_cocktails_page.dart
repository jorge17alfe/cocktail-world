import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';
import '../../services/public_api_service.dart';
import '../../widgets/public/async_state.dart';
import '../../widgets/public/cards.dart';
import '../../widgets/public/offline_banner.dart';
import 'cocktail_detail_page.dart';
import '../../widgets/public/centered_body.dart';

/// Cócteles de una familia, con buscador por nombre.
class FamilyCocktailsPage extends StatefulWidget {
  final String code;
  final Family family;
  final PublicApiService api;

  const FamilyCocktailsPage({super.key, required this.code, required this.family, required this.api});

  @override
  State<FamilyCocktailsPage> createState() => _FamilyCocktailsPageState();
}

class _FamilyCocktailsPageState extends State<FamilyCocktailsPage> {
  List<CocktailSummary>? _cocktails;
  DateTime? _offlineSince;
  Object? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final data = await widget.api.getFamily(widget.code, widget.family.id);
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

  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[áà]'), 'a')
      .replaceAll(RegExp('[éè]'), 'e')
      .replaceAll(RegExp('[íì]'), 'i')
      .replaceAll(RegExp('[óò]'), 'o')
      .replaceAll(RegExp('[úùü]'), 'u');

  @override
  Widget build(BuildContext context) {
    final all = _cocktails;
    final filtered = all?.where((c) => _normalize(c.name).contains(_normalize(_query))).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.family.name),
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
                    if (all.length > 6)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Buscar cóctel',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        ),
                      ),
                    if (filtered!.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyView(
                          icon: Icons.search_off,
                          message: all.isEmpty ? 'No hay cócteles en esta familia' : 'Ningún cóctel coincide',
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
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => CocktailCard(
                            cocktail: filtered[i],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CocktailDetailPage(
                                  code: widget.code,
                                  cocktailId: filtered[i].id,
                                  api: widget.api,
                                  initialName: filtered[i].name,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
