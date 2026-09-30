import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/expenses_screen.dart';
import 'package:spendly/services/expense_service.dart';
import 'package:spendly/widgets/expense_card.dart';

class MockExpensesScreenService extends ExpenseService {
  final List<Expense> expenses;

  MockExpensesScreenService(this.expenses);

  @override
  Stream<List<Expense>> getExpenses() {
    return Stream.value(expenses);
  }
}

void main() {
  group('ExpensesScreen (Expense History) Tests', () {
    testWidgets('Shows EmptyState when no expenses exist', (WidgetTester tester) async {
      final mockService = MockExpensesScreenService([]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No expenses yet'), findsOneWidget);
      expect(find.text('Add Expense'), findsOneWidget);
    });

    testWidgets('Shows expense history list and summary banner', (WidgetTester tester) async {
      final mockService = MockExpensesScreenService([
        Expense(
          id: '1',
          title: 'Electricity Bill',
          amount: 3200.0,
          category: ExpenseCategory.bills,
          date: DateTime(2026, 9, 10),
        ),
        Expense(
          id: '2',
          title: 'Movie Tickets',
          amount: 800.0,
          category: ExpenseCategory.entertainment,
          date: DateTime(2026, 9, 8),
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      // Check header records & total amount
      expect(find.text('2 Total Records'), findsOneWidget);
      expect(find.text('Rs. 4,000'), findsOneWidget);

      // Check expenses listed
      expect(find.text('Electricity Bill'), findsOneWidget);
      expect(find.text('Movie Tickets'), findsOneWidget);
      expect(find.widgetWithText(ExpenseCard, 'Bills'), findsOneWidget);
      expect(find.widgetWithText(ExpenseCard, 'Entertainment'), findsOneWidget);
    });
  });
}
