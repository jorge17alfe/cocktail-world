import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';
import 'app_network_image.dart';

/// Tarjeta de familia (cuadrícula).
class FamilyCard extends StatelessWidget {
  final Family family;
  final VoidCallback onTap;
  final Widget? trailing;

  const FamilyCard({super.key, required this.family, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = family.cocktailsCount;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: AppNetworkImage(url: family.imageUrl, placeholderIcon: Icons.wine_bar)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(family.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        if (count != null)
                          Text(count == 1 ? '1 cóctel' : '$count cócteles',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de cóctel (cuadrícula). [badge] se pinta sobre la foto (p. ej. "No publicado").
class CocktailCard extends StatelessWidget {
  final CocktailSummary cocktail;
  final VoidCallback onTap;
  final Widget? badge;

  const CocktailCard({super.key, required this.cocktail, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(fit: StackFit.expand, children: [
                AppNetworkImage(url: cocktail.imageUrl),
                if (badge != null) Positioned(top: 8, left: 8, child: badge!),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(cocktail.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  if (cocktail.price != null)
                    Text(formatPrice(cocktail.price!),
                        style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Etiqueta pequeña sobre las tarjetas.
class CardBadge extends StatelessWidget {
  final String text;
  final IconData? icon;

  const CardBadge(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: scheme.inverseSurface, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: scheme.onInverseSurface), const SizedBox(width: 4)],
        Text(text, style: TextStyle(color: scheme.onInverseSurface, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
