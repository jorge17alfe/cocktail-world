import 'package:flutter/material.dart';

/// Limita el ancho del contenido y lo centra (en tablet y ordenador no se queda pegado a la izquierda).
class CenteredBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredBody({super.key, required this.child, this.maxWidth = 1100});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
    );
  }
}
