import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';

/// Diálogo para crear o renombrar una familia. Devuelve (nombre, descripción) o null.
Future<({String name, String? description})?> showFamilyFormDialog(BuildContext context, {Family? family}) {
  return showDialog(context: context, builder: (_) => _FamilyFormDialog(family: family));
}

class _FamilyFormDialog extends StatefulWidget {
  final Family? family;

  const _FamilyFormDialog({this.family});

  @override
  State<_FamilyFormDialog> createState() => _FamilyFormDialogState();
}

class _FamilyFormDialogState extends State<_FamilyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.family?.name);
  late final _description = TextEditingController(text: widget.family?.description);

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final description = _description.text.trim();
    Navigator.pop(context, (name: _name.text.trim(), description: description.isEmpty ? null : description));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.family == null ? 'Nueva familia' : 'Editar familia'),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Clásicos, Internacionales...'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe un nombre' : null,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _submit, child: Text(widget.family == null ? 'Crear' : 'Guardar')),
      ],
    );
  }
}
