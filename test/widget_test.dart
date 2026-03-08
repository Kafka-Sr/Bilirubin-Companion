import 'package:bilirubin/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots dashboard', (tester) async {
    await tester.pumpWidget(const BilirubinApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });
}
