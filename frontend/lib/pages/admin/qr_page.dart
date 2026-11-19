import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../config/api_config.dart';
import '../../models/cocktail_models.dart';
import '../../widgets/admin/admin_ui.dart';

/// QR de la carta del local para poner en mesas y barra.
/// Lleva a la carta web (se abre con la cámara de cualquier móvil, sin instalar nada)
/// y la app también lo reconoce con "Escanear QR".
class QrPage extends StatelessWidget {
  final Establishment establishment;

  const QrPage({super.key, required this.establishment});

  String get url => establishment.publicUrl ?? '${ApiConfig.host}/carta/${establishment.code}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocalAddress = RegExp(r'//(localhost|127\.|10\.|192\.168\.|172\.(1[6-9]|2\d|3[01])\.)').hasMatch(url);

    return Scaffold(
      appBar: AppBar(title: const Text('QR de la carta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(establishment.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Nº ${establishment.code}', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
              const SizedBox(height: 20),
              // Fondo blanco siempre: los lectores de QR fallan con QR claros sobre fondo oscuro
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: QrImageView(
                    data: url,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                    semanticsLabel: 'QR de la carta de ${establishment.name}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Haz una captura de pantalla e imprímela para las mesas y la barra. '
                'Los clientes la abren con la cámara del móvil, sin instalar nada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              SelectableText(url, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (context.mounted) showSnack(context, 'Enlace copiado');
                },
                icon: const Icon(Icons.link),
                label: const Text('Copiar enlace'),
              ),
              if (isLocalAddress) ...[
                const SizedBox(height: 20),
                Card(
                  color: theme.colorScheme.tertiaryContainer,
                  child: const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Dirección de pruebas'),
                    subtitle: Text(
                        'Este enlace solo funciona en tu wifi. Cuando el servidor esté publicado en internet, el QR apuntará a la dirección definitiva.'),
                  ),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
