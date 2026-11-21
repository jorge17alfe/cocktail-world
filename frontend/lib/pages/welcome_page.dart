import 'package:flutter/material.dart';
import 'admin/admin_gate.dart';
import 'public/enter_code_page.dart';
import 'public/recipe_book_page.dart';
import '../services/public_api_service.dart';
import '../widgets/images/icons/app_icon.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppIcon(width: 180, height: 180, borderRadius: 40)),
                  const SizedBox(height: 20),
                  Text('Cocktail World',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: scheme.primary)),
                  const SizedBox(height: 8),
                  Text('Tus cócteles en acción.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 40),
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EnterCodePage()),
                    ),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                    icon: const Icon(Icons.local_bar),
                    label: const Text('Ver carta de cócteles', style: TextStyle(fontSize: 17)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminGate()),
                    ),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Acceso administrador', style: TextStyle(fontSize: 17)),
                  ),
                  const SizedBox(height: 20),
                  // Secundario a propósito: la app es para las cartas de los locales
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RecipeBookPage(api: PublicApiService())),
                      ),
                      style: TextButton.styleFrom(foregroundColor: scheme.onSurfaceVariant),
                      icon: const Icon(Icons.menu_book_outlined, size: 20),
                      label: const Text('Recetario de cócteles'),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Desarrollado por Alocraise',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
