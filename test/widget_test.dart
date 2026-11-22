import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nursing_adventure/main.dart';

void main() {
  testWidgets('Capsule Warriors smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CapsuleWarriorsApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('CAPSULE WARRIORS'), findsOneWidget);
    expect(find.text('THE STOMACH MISSION'), findsOneWidget);
    expect(find.text('Commencer la Mission'), findsOneWidget);
  });
}
