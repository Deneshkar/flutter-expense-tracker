import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/expenses_screen.dart';
import 'package:spendly/services/expense_service.dart';

class MockDeleteExpenseService extends ExpenseService {
  final List<Expense> expenses;
  String? deletedExpenseId;

  MockDeleteExpenseService(this.expenses);

  @override
  Stream<List<Expense>> getExpenses() {
    return Stream.value(expenses);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    deletedExpenseId = expenseId;
  }
}

void main() {
  group('Delete Expense Tests', () {
    final testExpense = Expense(
      id: 'del_123',
      title: 'Lunch with team',
      amount: 1200.0,
      category: ExpenseCategory.food,
      date: DateTime(2026, 9, 20),
    );

    testWidgets('Cancelling confirmation dialog does not delete expense', (WidgetTester tester) async {
      final mockService = MockDeleteExpenseService([testExpense]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      // Open popup menu on ExpenseCard
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      // Tap Delete in popup menu
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog is displayed
      expect(find.text('Delete Expense?'), findsOneWidget);

      // Tap Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify service was NOT called
      expect(mockService.deletedExpenseId, isNull);
    });

    testWidgets('Confirming dialog calls deleteExpense and displays SnackBar', (WidgetTester tester) async {
      final mockService = MockDeleteExpenseService([testExpense]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      // Open popup menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      // Tap Delete in popup menu
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Tap Delete in confirmation dialog
      // Look for the Delete button inside dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      // Verify service was called with the exact document ID
      expect(mockService.deletedExpenseId, 'del_123');

      // Verify SnackBar feedback
      expect(find.text('Deleted "Lunch with team"'), findsOneWidget);
    });
  });
}
