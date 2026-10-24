import 'package:flutter/material.dart';

const configuredSeed = int.fromEnvironment(
  'SEED_COLOR',
  defaultValue: 0xFF0F766E,
);

ThemeMode get configuredThemeMode {
  const value = String.fromEnvironment('APP_THEME', defaultValue: 'system');
  return switch (Uri.base.queryParameters['theme'] ?? value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

ThemeData buildTheme(Brightness brightness, {int seed = configuredSeed}) {
  final colors = ColorScheme.fromSeed(
    seedColor: Color(seed),
    brightness: brightness,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: colors);
  return base.copyWith(
    scaffoldBackgroundColor: colors.surfaceContainerLowest,
    textTheme: base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    appBarTheme: AppBarThemeData(
      centerTitle: true,
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
    ),
  );
}
