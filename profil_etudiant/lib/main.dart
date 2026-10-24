import 'package:flutter/material.dart';

const _seedColor = Color(0xFF0F766E);
const _appTheme = String.fromEnvironment('APP_THEME', defaultValue: 'system');

void main() => runApp(const MyApp());

/// Point d'entrée : les deux thèmes utilisent la même couleur de départ.
class MyApp extends StatelessWidget {
  const MyApp({super.key, this.themeMode});

  final ThemeMode? themeMode;

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    const buttonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, 48)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: const OutlinedButtonThemeData(style: buttonStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configuredTheme = switch (Uri.base.queryParameters['theme'] ??
        _appTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      title: 'Profil étudiant',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: themeMode ?? configuredTheme,
      home: const ProfilPage(),
    );
  }
}

/// Mini-projet statique : les coordonnées et les statistiques sont des exemples.
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Mon profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Semantics(
                      image: true,
                      label: 'Avatar GitHub d’Imrane Lakniti',
                      child: const CircleAvatar(
                        radius: 48,
                        backgroundImage: AssetImage('assets/images/avatar.jpg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Imrane Lakniti',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingénierie informatique · M2',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Contact', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 16),
                          const InfoRow(
                            icon: Icons.mail_outline,
                            label: 'E-mail',
                            text: 'imrane@example.com',
                          ),
                          const SizedBox(height: 16),
                          const InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Téléphone',
                            text: '+212 6 00 00 00 00',
                          ),
                          const SizedBox(height: 16),
                          const InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Ville',
                            text: 'Casablanca',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stat(value: '12', label: 'Projets'),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Stat(value: '3', label: 'Stages'),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Stat(value: 'M2', label: 'Niveau'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Expanded partage l'espace ; IntrinsicHeight aligne aussi
                  // les hauteurs lorsque les libellés passent sur deux lignes.
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => debugPrint('Contacter'),
                            child: const Text(
                              'Contacter',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => debugPrint('Télécharger'),
                            child: const Text(
                              'Télécharger',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Une ligne de coordonnées réutilisable qui laisse le texte se replier.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.label,
  });

  final IconData icon;
  final String text;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: label == null ? text : '$label : $text',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
          ],
        ),
      ),
    );
  }
}

/// Un indicateur composé d'une valeur et de son libellé.
class Stat extends StatelessWidget {
  const Stat({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$value $label',
      child: ExcludeSemantics(
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
