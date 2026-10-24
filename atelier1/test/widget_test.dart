import 'package:atelier1/src/app.dart';
import 'package:atelier1/src/pages.dart';
import 'package:atelier1/src/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final exercise in [
      Exercise.a,
      Exercise.b,
      Exercise.c,
      Exercise.d,
      Exercise.alignments,
    ]) {
      testWidgets('$exercise at 240px / text x2 in $mode has no overflow', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(240, 640);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MyApp(exercise: exercise, themeMode: mode, useNetworkImage: false),
        );
        await tester.pumpAndSettle();
        expect(find.text('Atelier Flutter'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Course action and FAB print the specified messages', (
    tester,
  ) async {
    final messages = <String?>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message);
    addTearDown(() => debugPrint = original);
    try {
      await tester.pumpWidget(
        const MyApp(exercise: Exercise.b, useNetworkImage: false),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.tap(find.byType(FloatingActionButton));
    } finally {
      debugPrint = original;
    }
    expect(
      messages,
      containsAllInOrder(['En savoir plus : cours Flutter', 'FAB cliqué']),
    );
  });

  testWidgets('Changing only the seed changes primary role colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(exercise: Exercise.c, themeMode: ThemeMode.light),
    );
    await tester.pumpAndSettle();
    final original = Theme.of(
      tester.element(find.byType(HomePage)),
    ).colorScheme.primary;
    await tester.pumpWidget(
      const MyApp(
        exercise: Exercise.c,
        themeMode: ThemeMode.light,
        seed: 0xFF7C3AED,
      ),
    );
    await tester.pumpAndSettle();
    final updated = Theme.of(
      tester.element(find.byType(HomePage)),
    ).colorScheme.primary;
    expect(updated, isNot(original));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expanded blocks share width in exact 1:2:1 proportions', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp(exercise: Exercise.c));
    await tester.pumpAndSettle();
    final blocks = find.byType(ProportionBlock);
    final a = tester.getSize(blocks.at(0));
    final b = tester.getSize(blocks.at(1));
    final c = tester.getSize(blocks.at(2));
    expect(a.height, 60);
    expect(b.width, closeTo(a.width * 2, 0.01));
    expect(c.width, closeTo(a.width, 0.01));
  });

  testWidgets('Broken teaching target produces a real RenderFlex diagnostic', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MyApp(exercise: Exercise.overflow));
    final error = tester.takeException();
    expect(longDescription.length, greaterThan(100));
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('A RenderFlex overflowed by'));
    // Captured by the test runner and recorded in docs/verification.
    debugPrint('EXPECTED_OVERFLOW: $error');
  });
}
