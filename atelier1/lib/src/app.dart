import 'package:flutter/material.dart';
import 'pages.dart';
import 'theme.dart';

enum Exercise { a, b, c, d, alignments, overflow }

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.exercise = Exercise.d,
    this.themeMode,
    this.seed = configuredSeed,
    this.useNetworkImage = true,
  });
  final Exercise exercise;
  final ThemeMode? themeMode;
  final int seed;
  final bool useNetworkImage;

  @override
  Widget build(BuildContext context) {
    final effectiveSeed =
        int.tryParse(Uri.base.queryParameters['seed'] ?? '') ?? seed;
    final lightTheme = buildTheme(Brightness.light, seed: effectiveSeed);
    return MaterialApp(
      title: 'Atelier Flutter',
      debugShowCheckedModeBanner: false,
      // Exercise A preserves the initial appearance, before D centralizes colors.
      theme: exercise == Exercise.a
          ? lightTheme.copyWith(scaffoldBackgroundColor: Colors.grey.shade100)
          : lightTheme,
      darkTheme: buildTheme(Brightness.dark, seed: effectiveSeed),
      themeMode: themeMode ?? configuredThemeMode,
      home: HomePage(exercise: exercise, useNetworkImage: useNetworkImage),
    );
  }
}
