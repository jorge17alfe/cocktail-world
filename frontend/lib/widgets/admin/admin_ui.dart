import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_client.dart';

void showSnack(BuildContext context, String message, {bool error = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? scheme.error : null,
      behavior: SnackBarBehavior.floating,
    ));
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Eliminar',
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: destructive ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError) : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Selector de fotos: galería (varias) o cámara si el dispositivo la tiene.
/// Las fotos se reducen a 1600 px y calidad 85 para que suban rápido.
class PhotoPicker {
  static final _picker = ImagePicker();

  static Future<List<UploadFile>> pick(BuildContext context, {int max = 10}) async {
    if (max <= 0) return [];

    ImageSource source = ImageSource.gallery;
    if (_picker.supportsImageSource(ImageSource.camera)) {
      final chosen = await showModalBottomSheet<ImageSource>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Hacer una foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ]),
        ),
      );
      if (chosen == null) return [];
      source = chosen;
    }

    final List<XFile> files;
    if (source == ImageSource.camera || max == 1) {
      final file = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      files = file == null ? [] : [file];
    } else {
      files = await _picker.pickMultiImage(maxWidth: 1600, imageQuality: 85, limit: max >= 2 ? max : null);
    }

    return [
      for (final f in files.take(max)) UploadFile(await f.readAsBytes(), f.name),
    ];
  }
}

/// Campo de texto con un menú de sugerencias habituales (copa, hielo, unidad...).
class SuggestTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final List<String> suggestions;
  final IconData? icon;
  final String? hint;

  const SuggestTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.suggestions,
    this.icon,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: PopupMenuButton<String>(
          tooltip: 'Sugerencias',
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: (v) => controller.text = v,
          itemBuilder: (_) => [for (final s in suggestions) PopupMenuItem(value: s, child: Text(s))],
        ),
      ),
    );
  }
}

/// Título de sección dentro de los formularios.
class FormSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const FormSectionTitle(this.title, {super.key, required this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
        ?trailing,
      ]),
    );
  }
}
