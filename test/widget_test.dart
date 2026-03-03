import 'package:bilirubin_companion/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BilirubinApp()));
    expect(find.text('Add baby'), findsOneWidget);
  });
}
