import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final String? assetPath;
  final double width;
  final double height;
  final Color? color;
  final BoxFit fit;
  final double borderRadius; // Nuevo parámetro para el radius

  const AppIcon({
    super.key,
    this.assetPath,
    this.width = 200,
    this.height = 200,
    this.color,
    this.fit = BoxFit.contain,
    this.borderRadius = 50.0, // Valor por defecto: sin radius
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        assetPath ?? 'assets/icons/iconbg.png',
        width: width,
        height: height,
        color: color,
        fit: fit,
      ),
    );
  }
}
