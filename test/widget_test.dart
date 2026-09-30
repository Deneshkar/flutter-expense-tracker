import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/main.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/services/expense_service.dart';

/// Simple in-memory mock service for testing UI without needing a live Firebase connection.
class TestExpenseService extends ExpenseService {
  final List<Expense> initialExpenses;

  TestExpenseService([this.initialExpenses = const []]);

  @override
  Stream<List<Expense>> getExpenses() {
    return Stream.value(initialExpenses);
  }
}

void main() {
  testWidgets('Spendly Home Screen smoke test', (WidgetTester tester) async {
    final mockService = TestExpenseService([
      Expense(
        id: '1',
        title: 'Lunch',
        amount: 850.0,
        category: ExpenseCategory.food,
        date: DateTime.now(),
      ),
    ]);

    // Build the app with test service
    await tester.pumpWidget(SpendlyApp(expenseService: mockService));
    await tester.pumpAndSettle();

    // Verify app title and content are displayed
    expect(find.text('Spendly'), findsOneWidget);
    expect(find.text('Total Spent'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
  });
}
