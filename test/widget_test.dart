import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nursing_adventure/main.dart';

void main() {
  testWidgets('Capsule Warriors smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CapsuleWarriorsApp());
    // Frame 1 immediately renders the interactive Home menu without a blocking spinner
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('JOUER'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('GASTRO QUEST'), findsWidgets);
    expect(find.text('CAPSULE WARRIORS • EXPÉDITION DIGESTIVE'), findsOneWidget);
    expect(find.text('REPRENDRE'), findsOneWidget);
    expect(find.text('COMMENT JOUER'), findsOneWidget);
    expect(find.text('PARAMÈTRES'), findsOneWidget);
    expect(find.text('PROGRESSION'), findsOneWidget);
    expect(find.text('SERVICES HOSPITALIERS'), findsOneWidget);

    await tester.tap(find.text('PROGRESSION'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('PROGRESSION & RÉCOMPENSES'), findsOneWidget);
    expect(find.text('VOIR LES 27 FICHES CLINIQUES'), findsOneWidget);
  });

  testWidgets('Intro screen auto-transitions to mission selection without stalling on logo', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CapsuleWarriorsApp());
    await tester.pump(const Duration(milliseconds: 750));

    // Clicking JOUER on a fresh save opens CapsuleWarriorsIntroScreen
    await tester.tap(find.text('JOUER'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('PASSER'), findsOneWidget);

    // Wait past the 4.2s intro + transition without pressing skip -> automatically arrives at Stage Select
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('CHOISISSEZ VOTRE MISSION'), findsOneWidget);
  });
}
