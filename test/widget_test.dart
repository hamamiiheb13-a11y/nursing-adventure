import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nursing_adventure/main.dart';

void main() {
  testWidgets('Gastro Quest smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const GastroQuestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('GASTRO QUEST'), findsOneWidget);
    expect(find.text('CARTE D\'AVENTURE (30 NIVEAUX)'), findsOneWidget);
  });
}
