import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/api_config.dart';
import '../../deep_link.dart';
import '../../models/cocktail_models.dart';
import '../../services/public_api_service.dart';
import '../../widgets/public/async_state.dart';
import '../../widgets/public/cocktail_detail_view.dart';
import '../../widgets/public/offline_banner.dart';
import 'recipe_book_page.dart';

/// Ficha de un cóctel del recetario público (misma vista que en la carta de un local).
class RecipeDetailPage extends StatefulWidget {
  final int cocktailId;
  final PublicApiService api;
  final String? initialName;

  const RecipeDetailPage({super.key, required this.cocktailId, required this.api, this.initialName});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Cocktail? _cocktail;
  DateTime? _offlineSince;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final data = await widget.api.getRecipe(widget.cocktailId);
      if (mounted) {
        setState(() {
          _cocktail = data.cocktail;
          _offlineSince = data.offlineSince;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _copyLink() async {
    final url = recetarioUrl(ApiConfig.host, widget.cocktailId);
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Enlace copiado: $url'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final cocktail = _cocktail;

    return Scaffold(
      appBar: AppBar(
        title: Text(cocktail?.name ?? widget.initialName ?? ''),
        // Abierta desde un enlace (no hay pantalla anterior): la flecha lleva al recetario
        leading: Navigator.of(context).canPop()
            ? null
            : IconButton(
                tooltip: 'Ver el recetario',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(
                  context,
                ).pushReplacement(MaterialPageRoute(builder: (_) => RecipeBookPage(api: widget.api))),
              ),
        actions: [IconButton(tooltip: 'Copiar enlace', icon: const Icon(Icons.link), onPressed: _copyLink)],
      ),
      body: _error != null && cocktail == null
          ? ErrorView(error: _error!, onRetry: _load)
          : cocktail == null
          ? const LoadingView()
          : CocktailDetailView(
              cocktail: cocktail,
              banner: _offlineSince == null ? null : OfflineBanner(since: _offlineSince),
            ),
    );
  }
}
