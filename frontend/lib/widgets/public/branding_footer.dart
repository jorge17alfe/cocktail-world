import 'package:flutter/material.dart';

import '../../pages/admin/admin_register_page.dart';
import '../../pages/public/recipe_book_page.dart';
import '../../services/admin_api_service.dart';
import '../../services/public_api_service.dart';

/// Firma discreta al final de la carta de un local:
/// "Carta creada con Cocktail World" + enlaces al recetario y al alta de locales.
class BrandingFooter extends StatelessWidget {
  final PublicApiService api;

  const BrandingFooter({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final linkStyle = TextButton.styleFrom(
      foregroundColor: muted,
      textStyle: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        children: [
          Divider(color: theme.colorScheme.outlineVariant, indent: 40, endIndent: 40),
          const SizedBox(height: 8),
          Text('Carta creada con Cocktail World', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                style: linkStyle,
                icon: const Icon(Icons.menu_book_outlined, size: 16),
                label: const Text('Ver recetario'),
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeBookPage(api: api))),
              ),
              Text('·', style: TextStyle(color: muted)),
              TextButton(
                style: linkStyle,
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => AdminRegisterPage(api: AdminApiService()))),
                child: const Text('¿Tienes un bar?'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
