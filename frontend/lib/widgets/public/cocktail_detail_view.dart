import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';
import 'app_network_image.dart';
import 'image_carousel.dart';

enum CocktailSection { ingredients, elaboration, history, utensils }

extension on CocktailSection {
  String get label => switch (this) {
        CocktailSection.ingredients => 'Ingredientes',
        CocktailSection.elaboration => 'Elaboración',
        CocktailSection.history => 'Historia',
        CocktailSection.utensils => 'Utensilios',
      };

  IconData get icon => switch (this) {
        CocktailSection.ingredients => Icons.liquor,
        CocktailSection.elaboration => Icons.format_list_numbered,
        CocktailSection.history => Icons.history_edu,
        CocktailSection.utensils => Icons.blender_outlined,
      };
}

/// Contenido de la ficha del cóctel (se usa en la vista pública y en la de admin).
class CocktailDetailView extends StatefulWidget {
  final Cocktail cocktail;

  /// Aviso opcional encima del contenido (p. ej. "No publicado").
  final Widget? banner;

  const CocktailDetailView({super.key, required this.cocktail, this.banner});

  @override
  State<CocktailDetailView> createState() => _CocktailDetailViewState();
}

class _CocktailDetailViewState extends State<CocktailDetailView> {
  CocktailSection _section = CocktailSection.ingredients;

  @override
  Widget build(BuildContext context) => _buildBody(context, widget.cocktail);

  Widget _buildBody(BuildContext context, Cocktail c) {
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      // En tablet / horizontal: carrusel a la izquierda y contenido a la derecha
      final wide = constraints.maxWidth >= 840;

      final header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.banner != null) widget.banner!,
          ClipRRect(
            borderRadius: BorderRadius.circular(wide ? 20 : 0),
            child: ImageCarousel(urls: c.images.map((i) => i.url).toList()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(c.name,
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    if (c.price != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Chip(
                          label: Text(formatPrice(c.price!)),
                          labelStyle: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                          backgroundColor: theme.colorScheme.primaryContainer,
                          side: BorderSide.none,
                        ),
                      ),
                  ],
                ),
                if (c.familyName != null)
                  Text(c.familyName!,
                      style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                _InfoChips(cocktail: c),
              ],
            ),
          ),
        ],
      );

      final sections = Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionButtons(selected: _section, onSelected: (s) => setState(() => _section = s)),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(key: ValueKey(_section), child: _sectionContent(c)),
            ),
          ],
        ),
      );

      if (wide) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: header)),
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.only(top: 20), child: sections)),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [header, sections]),
      );
    });
  }

  Widget _sectionContent(Cocktail c) => switch (_section) {
        CocktailSection.ingredients => _IngredientsView(ingredients: c.ingredients),
        CocktailSection.elaboration => _ElaborationView(cocktail: c),
        CocktailSection.history => _HistoryView(history: c.history),
        CocktailSection.utensils => _UtensilsView(utensils: c.utensils),
      };
}

/// Copa, técnica, hielo y decoración de un vistazo.
class _InfoChips extends StatelessWidget {
  final Cocktail cocktail;

  const _InfoChips({required this.cocktail});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String?)>[
      (Icons.wine_bar, 'Copa', cocktail.glass),
      (Icons.sync, 'Técnica', cocktail.techniqueLabel),
      (Icons.ac_unit, 'Hielo', cocktail.ice),
      (Icons.eco_outlined, 'Decoración', cocktail.garnish),
    ].where((e) => e.$3 != null && e.$3!.isNotEmpty).toList();

    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (icon, label, value) in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value),
                ])),
              ),
            ]),
          ),
      ],
    );
  }
}

class _SectionButtons extends StatelessWidget {
  final CocktailSection selected;
  final ValueChanged<CocktailSection> onSelected;

  const _SectionButtons({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: [
        for (final s in CocktailSection.values)
          Material(
            color: s == selected ? scheme.primary : scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSelected(s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(s.icon, color: s == selected ? scheme.onPrimary : scheme.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      s.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: s == selected ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _NoInfo extends StatelessWidget {
  final String text;

  const _NoInfo(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15)),
      );
}

/// Ingredientes con selector de nº de copas: multiplica las cantidades (útil para rondas o jarras).
class _IngredientsView extends StatefulWidget {
  final List<Ingredient> ingredients;

  const _IngredientsView({required this.ingredients});

  @override
  State<_IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<_IngredientsView> {
  static const _options = [1, 2, 4, 6, 8];
  int _servings = 1;

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.ingredients;
    if (ingredients.isEmpty) return const _NoInfo('Sin ingredientes registrados');
    final theme = Theme.of(context);
    final hasAmounts = ingredients.any((i) => i.amount != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasAmounts)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Text('Copas', style: theme.textTheme.titleSmall),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: [for (final n in _options) ButtonSegment(value: n, label: Text('×$n'))],
                    selected: {_servings},
                    onSelectionChanged: (s) => setState(() => _servings = s.first),
                  ),
                ),
              ),
            ]),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final (i, ing) in ingredients.indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 96,
                          child: Text(ing.quantityFor(_servings),
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ing.name, style: theme.textTheme.titleMedium),
                              if (ing.note != null && ing.note!.isNotEmpty)
                                Text(ing.note!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ElaborationView extends StatelessWidget {
  final Cocktail cocktail;

  const _ElaborationView({required this.cocktail});

  @override
  Widget build(BuildContext context) {
    final steps = cocktail.steps;
    if (steps.isEmpty) return const _NoInfo('Sin elaboración registrada');
    final theme = Theme.of(context);

    return Column(
      children: [
        for (final (i, step) in steps.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(step, style: theme.textTheme.bodyLarge?.copyWith(height: 1.4)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HistoryView extends StatelessWidget {
  final String? history;

  const _HistoryView({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history == null || history!.trim().isEmpty) return const _NoInfo('Sin historia registrada');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(history!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55)),
      ),
    );
  }
}

class _UtensilsView extends StatelessWidget {
  final List<Utensil> utensils;

  const _UtensilsView({required this.utensils});

  @override
  Widget build(BuildContext context) {
    if (utensils.isEmpty) return const _NoInfo('Sin utensilios registrados');
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: [
          for (final (i, u) in utensils.indexed) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: AppNetworkImage(url: u.imageUrl, placeholderIcon: Icons.blender_outlined),
                ),
              ),
              title: Text(u.name, style: theme.textTheme.titleMedium),
              subtitle: u.description == null ? null : Text(u.description!),
            ),
          ],
        ],
      ),
    );
  }
}
