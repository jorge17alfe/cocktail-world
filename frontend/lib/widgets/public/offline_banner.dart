import 'package:flutter/material.dart';

/// Aviso de que se están viendo datos guardados porque no hay conexión.
class OfflineBanner extends StatelessWidget {
  final DateTime? since;

  const OfflineBanner({super.key, required this.since});

  static String describe(DateTime d) {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final time = '${two(d.hour)}:${two(d.minute)}';
    final sameDay = d.year == now.year && d.month == now.month && d.day == now.day;
    return sameDay ? 'hoy a las $time' : 'el ${two(d.day)}/${two(d.month)}/${d.year} a las $time';
  }

  @override
  Widget build(BuildContext context) {
    if (since == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(Icons.cloud_off, size: 20, color: scheme.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Sin conexión · datos guardados ${describe(since!)}',
                style: TextStyle(color: scheme.onTertiaryContainer)),
          ),
        ]),
      ),
    );
  }
}
