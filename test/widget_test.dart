import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/main.dart';

void main() {
  testWidgets('Spendly basic smoke test', (WidgetTester tester) async {
    // Build the app shell
    await tester.pumpWidget(const SpendlyApp());

    // Verify that the title text is rendered
    expect(find.textContaining('Spendly'), findsOneWidget);
  });
}
