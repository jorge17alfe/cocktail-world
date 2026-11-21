import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/cocktail_models.dart';
import '../../services/admin_api_service.dart';
import '../../services/admin_session.dart';
import '../../widgets/admin/admin_ui.dart';
import '../../widgets/public/app_network_image.dart';
import '../../widgets/public/async_state.dart';
import '../../widgets/public/cocktail_detail_view.dart';
import '../../widgets/public/centered_body.dart';

/// Biblioteca base: elegir cócteles clásicos y copiarlos a una familia del local.
class LibraryPage extends StatefulWidget {
  final AdminSession session;
  final Family family;
  final AdminApiService? api;

  /// Abre el email de "¿Echas de menos un cóctel?" (se sustituye en los tests).
  final Future<bool> Function(Uri uri)? openUrl;

  const LibraryPage({super.key, required this.session, required this.family, this.api, this.openUrl});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late final AdminApiService _api = widget.api ?? AdminApiService.forSession(widget.session);

  List<CocktailSummary>? _items;
  Set<int> _alreadyCopied = {};
  final Set<int> _selected = {};
  Object? _error;
  String _query = '';
  String? _group;
  bool _copying = false;
  String? _supportEmail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    _loadSupportEmail();
    try {
      final results = await Future.wait([_api.library(), _api.cocktails()]);
      if (!mounted) return;
      setState(() {
        _items = results[0];
        _alreadyCopied = results[1].map((c) => c.sourceCocktailId).whereType<int>().toSet();
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Si falla no pasa nada: simplemente no se muestra el aviso.
  Future<void> _loadSupportEmail() async {
    try {
      final email = await _api.supportEmail();
      if (mounted) setState(() => _supportEmail = email);
    } catch (_) {}
  }

  Future<void> _askForCocktail() async {
    final email = _supportEmail;
    if (email == null) return;
    final local = widget.session.establishment;
    const subject = 'Cocktail World: cóctel para la biblioteca';
    final body =
        'Me gustaría que añadierais a la biblioteca: ${_query.trim()}'
        '\n\nLocal: ${local.name} (nº ${local.code})';
    final mailto = Uri(scheme: 'mailto', path: email, query: _encodeQuery({'subject': subject, 'body': body}));

    // Mismas opciones en el móvil y en la web: mailto solo funciona si hay una app de
    // correo configurada (en un PC muchas veces no la hay).
    final gmail = Uri.parse(
      'https://mail.google.com/mail/?${_encodeQuery({'view': 'cm', 'fs': '1', 'to': email, 'su': subject, 'body': body})}',
    );
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text('Escríbenos a $email', style: Theme.of(sheet).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copiar el email'),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: email));
                if (sheet.mounted) Navigator.pop(sheet);
                if (mounted) showSnack(context, 'Email copiado: $email');
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Escribir con Gmail'),
              onTap: () {
                Navigator.pop(sheet);
                _open(gmail, email);
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Abrir mi app de correo'),
              onTap: () {
                Navigator.pop(sheet);
                _open(mailto, email);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _open(Uri uri, String email) async {
    final opened = await (widget.openUrl ?? launchUrl)(uri);
    if (!opened && mounted) showSnack(context, 'No se pudo abrir el correo. Escríbenos a $email', error: true);
  }

  /// mailto necesita %20 para los espacios (Uri.queryParameters los convierte en "+").
  static String _encodeQuery(Map<String, String> params) =>
      params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');

  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[áà]'), 'a')
      .replaceAll(RegExp('[éè]'), 'e')
      .replaceAll(RegExp('[íì]'), 'i')
      .replaceAll(RegExp('[óò]'), 'o')
      .replaceAll(RegExp('[úùü]'), 'u');

  /// El primer tag de cada cóctel de la biblioteca es su grupo ("Clásicos", "Internacionales"...).
  List<String> get _groups => {
    for (final c in _items ?? <CocktailSummary>[])
      if (c.tags.isNotEmpty) c.tags.first,
  }.toList();

  List<CocktailSummary> get _visible {
    final q = _normalize(_query);
    return (_items ?? [])
        .where((c) => _group == null || (c.tags.isNotEmpty && c.tags.first == _group))
        .where((c) => q.isEmpty || _normalize(c.name).contains(q) || c.tags.any((t) => _normalize(t).contains(q)))
        .toList();
  }

  void _toggle(int id) => setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id));

  Future<void> _preview(CocktailSummary c) async {
    final add = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _LibraryPreviewPage(api: _api, summary: c, selected: _selected.contains(c.id)),
      ),
    );
    if (add != null) setState(() => add ? _selected.add(c.id) : _selected.remove(c.id));
  }

  Future<void> _copy() async {
    setState(() => _copying = true);
    try {
      final count = await _api.copyFromLibrary(widget.family.id, _selected.toList());
      if (!mounted) return;
      showSnack(context, '$count ${count == 1 ? 'cóctel añadido' : 'cócteles añadidos'} a ${widget.family.name}');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final visible = _visible;
    final allVisibleSelected = visible.isNotEmpty && visible.every((c) => _selected.contains(c.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de cócteles'),
        actions: [
          if (items != null && visible.isNotEmpty)
            TextButton(
              onPressed: () => setState(
                () => allVisibleSelected
                    ? _selected.removeAll(visible.map((c) => c.id))
                    : _selected.addAll(visible.map((c) => c.id)),
              ),
              child: Text(allVisibleSelected ? 'Ninguno' : 'Todos'),
            ),
        ],
      ),
      bottomNavigationBar: items == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: _selected.isEmpty || _copying ? null : _copy,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  icon: _copying
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.library_add),
                  label: Text(
                    _selected.isEmpty
                        ? 'Elige los cócteles que quieras añadir'
                        : 'Añadir ${_selected.length} a ${widget.family.name}',
                  ),
                ),
              ),
            ),
      body: CenteredBody(
        maxWidth: 760,
        child: _error != null && items == null
            ? ErrorView(error: _error!, onRetry: _load)
            : items == null
            ? const LoadingView()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o licor',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        ChoiceChip(
                          label: const Text('Todos'),
                          selected: _group == null,
                          onSelected: (_) => setState(() => _group = null),
                        ),
                        for (final g in _groups)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(g),
                              selected: _group == g,
                              onSelected: (_) => setState(() => _group = g),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: visible.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(
                                height: 280,
                                child: EmptyView(icon: Icons.search_off, message: 'Ningún cóctel coincide'),
                              ),
                              if (_supportEmail != null)
                                _MissingCocktailTile(email: _supportEmail!, onTap: _askForCocktail),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: visible.length + (_supportEmail != null ? 1 : 0),
                            itemBuilder: (context, i) => i == visible.length
                                ? _MissingCocktailTile(email: _supportEmail!, onTap: _askForCocktail)
                                : _LibraryTile(
                                    cocktail: visible[i],
                                    selected: _selected.contains(visible[i].id),
                                    alreadyCopied: _alreadyCopied.contains(visible[i].id),
                                    onToggle: () => _toggle(visible[i].id),
                                    onPreview: () => _preview(visible[i]),
                                  ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Al final de la biblioteca: pedir a Alocraise un cóctel que falta.
class _MissingCocktailTile extends StatelessWidget {
  final String email;
  final VoidCallback onTap;

  const _MissingCocktailTile({required this.email, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(Icons.local_bar_outlined, color: theme.colorScheme.primary),
          title: const Text('¿Echas de menos un cóctel?', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Escríbenos a $email y lo añadimos a la biblioteca'),
          trailing: const Icon(Icons.mail_outline),
        ),
      ),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  final CocktailSummary cocktail;
  final bool selected;
  final bool alreadyCopied;
  final VoidCallback onToggle;
  final VoidCallback onPreview;

  const _LibraryTile({
    required this.cocktail,
    required this.selected,
    required this.alreadyCopied,
    required this.onToggle,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onToggle,
      selected: selected,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: 56, height: 56, child: AppNetworkImage(url: cocktail.imageUrl)),
      ),
      title: Text(cocktail.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cocktail.tags.isNotEmpty) Text(cocktail.tags.join(' · ')),
          if (alreadyCopied)
            Text(
              'Ya está en tu carta',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(tooltip: 'Ver ficha', icon: const Icon(Icons.visibility_outlined), onPressed: onPreview),
          Checkbox(value: selected, onChanged: (_) => onToggle()),
        ],
      ),
    );
  }
}

/// Vista previa de un cóctel de la biblioteca. Devuelve true/false para marcarlo o desmarcarlo.
class _LibraryPreviewPage extends StatefulWidget {
  final AdminApiService api;
  final CocktailSummary summary;
  final bool selected;

  const _LibraryPreviewPage({required this.api, required this.summary, required this.selected});

  @override
  State<_LibraryPreviewPage> createState() => _LibraryPreviewPageState();
}

class _LibraryPreviewPageState extends State<_LibraryPreviewPage> {
  Cocktail? _cocktail;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final c = await widget.api.libraryCocktail(widget.summary.id);
      if (mounted) setState(() => _cocktail = c);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _cocktail;

    return Scaffold(
      appBar: AppBar(title: Text(widget.summary.name)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: widget.selected
              ? OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Quitar de la selección'),
                )
              : FilledButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  icon: const Icon(Icons.add),
                  label: const Text('Seleccionar este cóctel'),
                ),
        ),
      ),
      body: _error != null && c == null
          ? ErrorView(error: _error!, onRetry: _load)
          : c == null
          ? const LoadingView()
          : CocktailDetailView(cocktail: c),
    );
  }
}
