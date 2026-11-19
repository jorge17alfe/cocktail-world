import 'package:flutter/material.dart';

import '../../models/cocktail_models.dart';
import '../../services/admin_api_service.dart';
import '../../services/admin_session.dart';
import '../../widgets/admin/admin_ui.dart';
import '../../widgets/public/app_network_image.dart';
import '../../widgets/public/async_state.dart';

const _maxPhotos = 10;
const _glassSuggestions = [
  'Copa de cóctel', 'Copa martini', 'Copa margarita', 'Copa de vino', 'Copa balón',
  'Vaso old fashioned', 'Vaso highball', 'Vaso hurricane', 'Taza de cobre', 'Vaso tiki',
];
const _iceSuggestions = ['Cubos', 'Hielo picado', 'Bloque grande', 'Sin hielo en copa'];
const _unitSuggestions = ['ml', 'cl', 'oz', 'golpes', 'gotas', 'hojas', 'unidad', 'cucharaditas', 'chorrito', 'rodaja'];

/// Foto del carrusel: ya subida (remote) o elegida pero aún sin subir (local).
class _Photo {
  final CocktailImage? remote;
  final UploadFile? local;
  final Key key = UniqueKey();

  _Photo.remote(CocktailImage image) : remote = image, local = null;
  _Photo.local(UploadFile file) : remote = null, local = file;
}

class _IngredientRow {
  final Key key = UniqueKey();
  final TextEditingController name, amount, unit, note;

  _IngredientRow([Ingredient? i])
      : name = TextEditingController(text: i?.name),
        amount = TextEditingController(text: i?.amount == null ? '' : Ingredient.formatAmount(i!.amount!)),
        unit = TextEditingController(text: i?.unit),
        note = TextEditingController(text: i?.note);

  bool get isBlank => [name, amount, unit, note].every((c) => c.text.trim().isEmpty);

  void dispose() {
    for (final c in [name, amount, unit, note]) {
      c.dispose();
    }
  }
}

class _StepRow {
  final Key key = UniqueKey();
  final TextEditingController text;

  _StepRow([String? step]) : text = TextEditingController(text: step);
}

String? _clean(TextEditingController c) {
  final v = c.text.trim();
  return v.isEmpty ? null : v;
}

double? _parseNumber(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

/// Crear o editar la ficha de un cóctel: fotos, datos, ingredientes, elaboración, historia y utensilios.
class CocktailEditorPage extends StatefulWidget {
  final AdminSession session;
  final int familyId;
  final Cocktail? existing;
  final AdminApiService? api;

  const CocktailEditorPage({super.key, required this.session, required this.familyId, this.existing, this.api});

  @override
  State<CocktailEditorPage> createState() => _CocktailEditorPageState();
}

class _CocktailEditorPageState extends State<CocktailEditorPage> {
  late final AdminApiService _api = widget.api ?? AdminApiService.forSession(widget.session);
  final _formKey = GlobalKey<FormState>();

  List<Family>? _families;
  List<Utensil>? _utensils;
  Object? _loadError;

  late final _name = TextEditingController(text: widget.existing?.name);
  late final _price = TextEditingController(
      text: widget.existing?.price == null ? '' : widget.existing!.price!.toStringAsFixed(2).replaceAll('.', ','));
  late final _glass = TextEditingController(text: widget.existing?.glass);
  late final _ice = TextEditingController(text: widget.existing?.ice);
  late final _garnish = TextEditingController(text: widget.existing?.garnish);
  late final _history = TextEditingController(text: widget.existing?.history);

  late int _familyId = widget.familyId;
  late String? _technique = widget.existing?.technique;
  late bool _published = widget.existing?.isPublished ?? true;
  late final Set<int> _utensilIds = {...?widget.existing?.utensils.map((u) => u.id)};

  late final List<_IngredientRow> _ingredients = widget.existing == null || widget.existing!.ingredients.isEmpty
      ? [_IngredientRow(), _IngredientRow()]
      : widget.existing!.ingredients.map(_IngredientRow.new).toList();
  late final List<_StepRow> _steps = widget.existing == null || widget.existing!.steps.isEmpty
      ? [_StepRow()]
      : widget.existing!.steps.map(_StepRow.new).toList();

  late final List<_Photo> _photos = [...?widget.existing?.images.map(_Photo.remote)];
  final List<int> _removedImageIds = [];

  /// Id en el servidor (si se crea y luego falla la subida de fotos, el reintento no duplica el cóctel).
  late int? _savedId = widget.existing?.id;

  bool _dirty = false;
  String? _savingLabel;

  bool get _isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    for (final c in [_name, _price, _glass, _ice, _garnish, _history]) {
      c.dispose();
    }
    for (final r in _ingredients) {
      r.dispose();
    }
    for (final s in _steps) {
      s.text.dispose();
    }
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() => _loadError = null);
    try {
      final results = await Future.wait([_api.families(), _api.utensils()]);
      if (!mounted) return;
      setState(() {
        _families = results[0] as List<Family>;
        _utensils = results[1] as List<Utensil>;
      });
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _update(VoidCallback change) {
    setState(change);
    _dirty = true;
  }

  // ---------------------------------------------------------------- Guardar

  Future<void> _save() async {
    if (_savingLabel != null) return;
    if (!_formKey.currentState!.validate()) {
      showSnack(context, 'Revisa los campos marcados', error: true);
      return;
    }

    final ingredients = <Ingredient>[];
    for (final r in _ingredients) {
      if (r.isBlank) continue;
      if (r.name.text.trim().isEmpty) {
        showSnack(context, 'A un ingrediente le falta el nombre', error: true);
        return;
      }
      ingredients.add(Ingredient(
        name: r.name.text.trim(),
        amount: _parseNumber(r.amount.text),
        unit: _clean(r.unit),
        note: _clean(r.note),
      ));
    }

    final input = CocktailInput(
      familyId: _familyId,
      name: _name.text.trim(),
      price: _parseNumber(_price.text),
      isPublished: _published,
      glass: _clean(_glass),
      technique: _technique,
      ice: _clean(_ice),
      garnish: _clean(_garnish),
      history: _clean(_history),
      steps: _steps.map((s) => s.text.text.trim()).where((s) => s.isNotEmpty).toList(),
      ingredients: ingredients,
      utensilIds: _utensilIds.toList(),
    );

    try {
      setState(() => _savingLabel = 'Guardando ficha…');
      final id = _savedId;
      final saved = id == null ? await _api.createCocktail(input) : await _api.updateCocktail(id, input);
      _savedId = saved.id;

      await _syncPhotos(saved.id);

      if (!mounted) return;
      _dirty = false;
      showSnack(context, _isNew ? 'Cóctel creado' : 'Cambios guardados');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _savingLabel = null);
    }
  }

  /// Borra las fotos quitadas, sube las nuevas y deja el orden tal como se ve en pantalla.
  Future<void> _syncPhotos(int cocktailId) async {
    var serverImages = <CocktailImage>[];

    for (final id in List.of(_removedImageIds)) {
      if (mounted) setState(() => _savingLabel = 'Quitando fotos…');
      serverImages = await _api.deleteCocktailImage(cocktailId, id);
      _removedImageIds.remove(id);
    }

    final locals = _photos.where((p) => p.local != null).toList();
    if (locals.isNotEmpty) {
      if (mounted) setState(() => _savingLabel = 'Subiendo ${locals.length} ${locals.length == 1 ? 'foto' : 'fotos'}…');
      final before = _photos.where((p) => p.remote != null).map((p) => p.remote!.id).toSet();
      serverImages = await _api.uploadCocktailImages(cocktailId, locals.map((p) => p.local!).toList());

      // Las nuevas llegan al final y en el mismo orden en que se subieron
      final uploaded = serverImages.where((img) => !before.contains(img.id)).toList();
      var next = 0;
      for (var i = 0; i < _photos.length && next < uploaded.length; i++) {
        if (_photos[i].local != null) _photos[i] = _Photo.remote(uploaded[next++]);
      }
    }

    final wanted = _photos.where((p) => p.remote != null).map((p) => p.remote!.id).toList();
    final current = serverImages.isEmpty ? (widget.existing?.images.map((i) => i.id).toList() ?? []) : serverImages.map((i) => i.id).toList();
    final currentKept = current.where(wanted.contains).toList();
    if (wanted.length > 1 && !_sameOrder(wanted, currentKept)) {
      if (mounted) setState(() => _savingLabel = 'Ordenando fotos…');
      await _api.reorderCocktailImages(cocktailId, wanted);
    }
  }

  static bool _sameOrder(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------- Acciones

  Future<void> _addPhotos() async {
    final files = await PhotoPicker.pick(context, max: _maxPhotos - _photos.length);
    if (files.isEmpty) return;
    _update(() => _photos.addAll(files.map(_Photo.local)));
  }

  void _removePhoto(_Photo photo) {
    _update(() {
      _photos.remove(photo);
      if (photo.remote != null) _removedImageIds.add(photo.remote!.id);
    });
  }

  Future<void> _newUtensil() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo utensilio'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ej. Ahumador'),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Añadir')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;

    try {
      final utensil = await _api.createUtensil(name);
      _update(() {
        _utensils = [..._utensils!, utensil]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _utensilIds.add(utensil.id);
      });
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    }
  }

  void _move<T>(List<T> list, int index, int delta) {
    final to = index + delta;
    if (to < 0 || to >= list.length) return;
    _update(() => list.insert(to, list.removeAt(index)));
  }

  Future<bool> _confirmDiscard() => confirmDialog(
        context,
        title: 'Descartar cambios',
        message: 'Tienes cambios sin guardar. ¿Salir sin guardar?',
        confirmLabel: 'Descartar',
      );

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final ready = _families != null && _utensils != null;
    final saving = _savingLabel != null;

    return PopScope(
      canPop: !_dirty && !saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || saving) return;
        if (await _confirmDiscard() && context.mounted) {
          _dirty = false;
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? 'Nuevo cóctel' : 'Editar cóctel'),
          actions: [
            if (ready)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.icon(
                  onPressed: saving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Guardar'),
                ),
              ),
          ],
          bottom: saving
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(28),
                  child: Column(children: [
                    Text(_savingLabel!, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    const LinearProgressIndicator(),
                  ]),
                )
              : null,
        ),
        body: _loadError != null
            ? ErrorView(error: _loadError!, onRetry: _loadOptions)
            : !ready
                ? const LoadingView()
                : AbsorbPointer(absorbing: saving, child: _buildForm(context)),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final families = _families!;
    // Si la familia de entrada ya no existe (borrada desde otro dispositivo), se usa la primera
    if (!families.any((f) => f.id == _familyId) && families.isNotEmpty) _familyId = families.first.id;

    return Form(
      key: _formKey,
      onChanged: _markDirty,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
            children: [
              _photosSection(context),
              _dataSection(families),
              _serviceSection(),
              _ingredientsSection(context),
              _stepsSection(context),
              const FormSectionTitle('Historia', icon: Icons.history_edu),
              TextFormField(
                controller: _history,
                minLines: 4,
                maxLines: 12,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Origen, anécdotas, quién lo creó...',
                  alignLabelWithHint: true,
                ),
              ),
              _utensilsSection(context),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _savingLabel != null ? null : _save,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                icon: const Icon(Icons.check),
                label: Text(_isNew ? 'Crear cóctel' : 'Guardar cambios', style: const TextStyle(fontSize: 17)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photosSection(BuildContext context) {
    final theme = Theme.of(context);
    final canAdd = _photos.length < _maxPhotos;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FormSectionTitle('Fotos',
          icon: Icons.photo_library_outlined,
          trailing: Text('${_photos.length}/$_maxPhotos', style: theme.textTheme.labelLarge)),
      SizedBox(
        height: 124,
        child: ReorderableListView.builder(
          scrollDirection: Axis.horizontal,
          buildDefaultDragHandles: false,
          itemCount: _photos.length,
          onReorder: (from, to) => _update(() {
            if (to > from) to--;
            _photos.insert(to, _photos.removeAt(from));
          }),
          footer: canAdd
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _AddPhotoTile(onTap: _addPhotos),
                )
              : null,
          itemBuilder: (context, i) {
            final photo = _photos[i];
            return ReorderableDelayedDragStartListener(
              key: photo.key,
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PhotoTile(photo: photo, isCover: i == 0, onRemove: () => _removePhoto(photo)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 6),
      Text(
        _photos.length > 1
            ? 'Mantén pulsada una foto y arrástrala para cambiar el orden. La primera es la portada.'
            : 'La primera foto será la portada en la carta.',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    ]);
  }

  Widget _dataSection(List<Family> families) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const FormSectionTitle('Datos', icon: Icons.badge_outlined),
      TextFormField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Nombre del cóctel *', prefixIcon: Icon(Icons.local_bar)),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
      ),
      const SizedBox(height: 14),
      DropdownButtonFormField<int>(
        initialValue: _familyId,
        decoration: const InputDecoration(labelText: 'Familia', prefixIcon: Icon(Icons.wine_bar)),
        items: [for (final f in families) DropdownMenuItem(value: f.id, child: Text(f.name))],
        onChanged: (v) => _update(() => _familyId = v!),
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _price,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Precio (opcional)',
          prefixIcon: Icon(Icons.euro),
          helperText: 'Déjalo vacío si no quieres mostrar precio',
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return null;
          final n = _parseNumber(v);
          return (n == null || n < 0) ? 'Precio no válido' : null;
        },
      ),
      const SizedBox(height: 8),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Publicado'),
        subtitle: Text(_published ? 'Visible para clientes y camareros' : 'Oculto: solo lo ves tú'),
        value: _published,
        onChanged: (v) => _update(() => _published = v),
      ),
    ]);
  }

  Widget _serviceSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const FormSectionTitle('Servicio', icon: Icons.wine_bar_outlined),
      SuggestTextField(controller: _glass, label: 'Copa / vaso', icon: Icons.wine_bar, suggestions: _glassSuggestions),
      const SizedBox(height: 14),
      DropdownButtonFormField<String?>(
        initialValue: Cocktail.techniqueLabels.containsKey(_technique) ? _technique : null,
        decoration: const InputDecoration(labelText: 'Técnica', prefixIcon: Icon(Icons.sync)),
        items: [
          const DropdownMenuItem(value: null, child: Text('Sin especificar')),
          for (final e in Cocktail.techniqueLabels.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
        ],
        onChanged: (v) => _update(() => _technique = v),
      ),
      const SizedBox(height: 14),
      SuggestTextField(controller: _ice, label: 'Hielo', icon: Icons.ac_unit, suggestions: _iceSuggestions),
      const SizedBox(height: 14),
      TextFormField(
        controller: _garnish,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Decoración', prefixIcon: Icon(Icons.eco_outlined)),
      ),
    ]);
  }

  Widget _ingredientsSection(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const FormSectionTitle('Ingredientes', icon: Icons.liquor),
      for (final (i, row) in _ingredients.indexed)
        Card(
          key: row.key,
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: row.name,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: 'Ingrediente ${i + 1}', isDense: true),
                  ),
                ),
                _RowMenu(
                  onUp: i > 0 ? () => _move(_ingredients, i, -1) : null,
                  onDown: i < _ingredients.length - 1 ? () => _move(_ingredients, i, 1) : null,
                  onDelete: () => _update(() => _ingredients.removeAt(i).dispose()),
                ),
              ]),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(children: [
                  SizedBox(
                    width: 84,
                    child: TextFormField(
                      controller: row.amount,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Cant.', isDense: true),
                      validator: (v) =>
                          (v != null && v.trim().isNotEmpty && _parseNumber(v) == null) ? 'Número' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SuggestTextField(controller: row.unit, label: 'Unidad', suggestions: _unitSuggestions),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: row.note,
                      decoration: const InputDecoration(labelText: 'Nota', hintText: 'opcional', isDense: true),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () => _update(() => _ingredients.add(_IngredientRow())),
          icon: const Icon(Icons.add),
          label: const Text('Añadir ingrediente'),
        ),
      ),
    ]);
  }

  Widget _stepsSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const FormSectionTitle('Elaboración', icon: Icons.format_list_numbered),
      for (final (i, step) in _steps.indexed)
        Padding(
          key: step.key,
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: step.text,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: 'Paso ${i + 1}'),
              ),
            ),
            _RowMenu(
              onUp: i > 0 ? () => _move(_steps, i, -1) : null,
              onDown: i < _steps.length - 1 ? () => _move(_steps, i, 1) : null,
              onDelete: () => _update(() => _steps.removeAt(i).text.dispose()),
            ),
          ]),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () => _update(() => _steps.add(_StepRow())),
          icon: const Icon(Icons.add),
          label: const Text('Añadir paso'),
        ),
      ),
    ]);
  }

  Widget _utensilsSection(BuildContext context) {
    final utensils = _utensils!;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      FormSectionTitle('Utensilios',
          icon: Icons.blender_outlined,
          trailing: _utensilIds.isEmpty ? null : Text('${_utensilIds.length} elegidos')),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final u in utensils)
            FilterChip(
              label: Text(u.name),
              selected: _utensilIds.contains(u.id),
              onSelected: (on) => _update(() => on ? _utensilIds.add(u.id) : _utensilIds.remove(u.id)),
            ),
          ActionChip(avatar: const Icon(Icons.add, size: 18), label: const Text('Nuevo utensilio'), onPressed: _newUtensil),
        ],
      ),
    ]);
  }
}

class _RowMenu extends StatelessWidget {
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback onDelete;

  const _RowMenu({required this.onUp, required this.onDown, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VoidCallback>(
      tooltip: 'Opciones',
      onSelected: (action) => action(),
      itemBuilder: (_) => [
        PopupMenuItem(
            value: onUp, enabled: onUp != null, child: const ListTile(leading: Icon(Icons.arrow_upward), title: Text('Subir'))),
        PopupMenuItem(
            value: onDown,
            enabled: onDown != null,
            child: const ListTile(leading: Icon(Icons.arrow_downward), title: Text('Bajar'))),
        PopupMenuItem(value: onDelete, child: const ListTile(leading: Icon(Icons.delete_outline), title: Text('Quitar'))),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final _Photo photo;
  final bool isCover;
  final VoidCallback onRemove;

  const _PhotoTile({required this.photo, required this.isCover, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(fit: StackFit.expand, children: [
          photo.local != null
              ? Image.memory(photo.local!.bytes, fit: BoxFit.cover)
              : AppNetworkImage(url: photo.remote!.url),
          if (isCover)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: scheme.primary.withValues(alpha: 0.85),
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('Portada',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          if (photo.local != null)
            Positioned(
              left: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: scheme.tertiary, borderRadius: BorderRadius.circular(6)),
                child: Text('Nueva', style: TextStyle(color: scheme.onTertiary, fontSize: 11)),
              ),
            ),
          Positioned(
            right: 4,
            top: 4,
            child: IconButton.filled(
              tooltip: 'Quitar foto',
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
              iconSize: 18,
              onPressed: onRemove,
              icon: const Icon(Icons.close),
            ),
          ),
        ]),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 120,
          height: 120,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_a_photo_outlined, size: 32, color: scheme.primary),
            const SizedBox(height: 6),
            Text('Añadir fotos', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
