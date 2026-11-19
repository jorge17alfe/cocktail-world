import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';
import '../../services/public_api_service.dart';
import '../../widgets/public/async_state.dart';
import '../../widgets/public/cocktail_detail_view.dart';
import '../../widgets/public/offline_banner.dart';
import 'families_page.dart';

/// Ficha pública del cóctel: nombre, carrusel y botones de Ingredientes / Elaboración / Historia / Utensilios.
class CocktailDetailPage extends StatefulWidget {
  final String code;
  final int cocktailId;
  final PublicApiService api;
  final String? initialName;

  const CocktailDetailPage({
    super.key,
    required this.code,
    required this.cocktailId,
    required this.api,
    this.initialName,
  });

  @override
  State<CocktailDetailPage> createState() => _CocktailDetailPageState();
}

class _CocktailDetailPageState extends State<CocktailDetailPage> {
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
      final data = await widget.api.getCocktail(widget.code, widget.cocktailId);
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

  @override
  Widget build(BuildContext context) {
    final cocktail = _cocktail;

    return Scaffold(
      appBar: AppBar(
        title: Text(cocktail?.name ?? widget.initialName ?? ''),
        // Abierta desde un enlace (no hay pantalla anterior): la flecha lleva a la carta del local
        leading: Navigator.of(context).canPop()
            ? null
            : IconButton(
                tooltip: 'Ver la carta',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => FamiliesPage(code: widget.code, api: widget.api),
                )),
              ),
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
