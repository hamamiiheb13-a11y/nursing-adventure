import 'package:flutter_test/flutter_test.dart';
import 'package:nursing_adventure/main.dart';

void main() {
  testWidgets('Nursing Adventure smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NursingAdventureApp());
    // Pump frames to let initial layout render
    await tester.pump(const Duration(milliseconds: 500));

    // Verify title and PLAY NOW button appear
    expect(find.text('NURSING ADVENTURE'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsOneWidget);
  });
}
