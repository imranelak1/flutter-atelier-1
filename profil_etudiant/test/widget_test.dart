import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profil_etudiant/main.dart';

void main() {
  testWidgets('Le profil affiche le contenu demandé et les deux actions', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp(themeMode: ThemeMode.light));
    await tester.pumpAndSettle();

    expect(find.text('Mon profil'), findsOneWidget);
    expect(find.text('Imrane Lakniti'), findsOneWidget);
    expect(find.text('Ingénierie informatique · M2'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(InfoRow), findsNWidgets(3));
    expect(find.byType(Stat), findsNWidgets(3));
    expect(find.text('imrane@example.com'), findsOneWidget);
    expect(find.text('+212 6 00 00 00 00'), findsOneWidget);
    expect(find.text('Casablanca'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('M2'), findsOneWidget);

    final contact = tester.getSize(find.byType(ElevatedButton));
    final download = tester.getSize(find.byType(OutlinedButton));
    expect(contact.width, closeTo(download.width, 0.1));
    expect(contact.height, greaterThanOrEqualTo(48));
    expect(download.height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Les boutons simulent leur action avec debugPrint', (
    tester,
  ) async {
    final messages = <String?>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message);
    try {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.ensureVisible(find.byType(OutlinedButton));
      await tester.tap(find.byType(OutlinedButton));

      expect(messages, containsAllInOrder(['Contacter', 'Télécharger']));
    } finally {
      debugPrint = originalDebugPrint;
    }
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in [
      const Size(240, 640),
      const Size(390, 844),
      const Size(844, 390),
    ]) {
      testWidgets('Le profil reste lisible en $mode à $size et texte ×2', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(MyApp(themeMode: mode));
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(ProfilPage));
        expect(
          Theme.of(context).brightness,
          mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
        );
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.byType(OutlinedButton));
        await tester.pumpAndSettle();
        expect(find.byType(OutlinedButton).hitTestable(), findsOneWidget);
        expect(
          tester.getSize(find.byType(ElevatedButton)).width,
          closeTo(tester.getSize(find.byType(OutlinedButton)).width, 0.1),
        );
        await tester.ensureVisible(find.text('Niveau'));
        await tester.pumpAndSettle();
        expect(find.text('Niveau').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('InfoRow replie une longue adresse sans débordement', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(240, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    const address = 'prenom.nom.tres.long.pour.le.test@example.com';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: InfoRow(icon: Icons.mail_outline, text: address),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(address), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
