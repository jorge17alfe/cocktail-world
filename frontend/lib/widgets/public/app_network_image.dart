import 'package:flutter/material.dart';

/// Imagen de red con placeholder mientras carga y si falla o no hay URL.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final IconData placeholderIcon;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.local_bar,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder(context);

    return Image.network(
      url!,
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Stack(fit: StackFit.expand, children: [
              _placeholder(context),
              const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
            ]),
      errorBuilder: (context, _, _) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.tertiaryContainer],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) => Center(
          child: Icon(placeholderIcon,
              size: (c.biggest.shortestSide * 0.4).clamp(20, 72), color: scheme.onPrimaryContainer.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}
