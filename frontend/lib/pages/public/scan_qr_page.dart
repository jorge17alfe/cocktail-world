import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Escanea el QR de un local y devuelve su número de establecimiento.
class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  /// El escáner solo funciona en móvil (Android / iOS).
  static bool get isSupported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  /// Acepta la URL de la carta web (…/carta/123456) o directamente el número.
  static String? codeFrom(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    final fromUrl = RegExp(r'/carta/(\d{4,12})(?:[/?#]|$)').firstMatch(text);
    if (fromUrl != null) return fromUrl.group(1);
    return RegExp(r'^\d{4,12}$').hasMatch(text) ? text : null;
  }

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  bool _done = false;
  String? _invalid;

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final barcode in capture.barcodes) {
      final code = ScanQrPage.codeFrom(barcode.rawValue);
      if (code != null) {
        _done = true;
        Navigator.of(context).pop(code);
        return;
      }
    }
    if (_invalid == null) setState(() => _invalid = 'Este QR no es de una carta de cócteles');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear QR del local'),
      ),
      body: Stack(children: [
        MobileScanner(
          onDetect: _onDetect,
          errorBuilder: (context, error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                error.errorCode == MobileScannerErrorCode.permissionDenied
                    ? 'Necesitas dar permiso de cámara para escanear'
                    : 'No se pudo abrir la cámara',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 48,
          child: Text(
            _invalid ?? 'Apunta al código QR de la mesa o de la barra',
            textAlign: TextAlign.center,
            style: TextStyle(color: _invalid == null ? Colors.white : Colors.amberAccent, fontSize: 16),
          ),
        ),
      ]),
    );
  }
}
