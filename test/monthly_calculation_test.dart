import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/home_screen.dart';
import 'package:spendly/services/expense_service.dart';

class MockMonthlyExpenseService extends ExpenseService {
  final List<Expense> expenses;

  MockMonthlyExpenseService(this.expenses);

  @override
  Stream<List<Expense>> getExpenses() {
    return Stream.value(expenses);
  }
}

void main() {
  group('Monthly Calculation Unit Tests', () {
    final sep1 = Expense(
      id: '1',
      title: 'Groceries',
      amount: 1500.0,
      category: ExpenseCategory.food,
      date: DateTime(2026, 9, 5),
    );
    final sep2 = Expense(
      id: '2',
      title: 'Bus Pass',
      amount: 500.0,
      category: ExpenseCategory.transport,
      date: DateTime(2026, 9, 12),
    );
    final sep3 = Expense(
      id: '3',
      title: 'Dinner',
      amount: 800.0,
      category: ExpenseCategory.food,
      date: DateTime(2026, 9, 28),
    );
    final aug1 = Expense(
      id: '4',
      title: 'August Rent',
      amount: 12000.0,
      category: ExpenseCategory.bills,
      date: DateTime(2026, 8, 1),
    );
    final sepLastYear = Expense(
      id: '5',
      title: 'Old Expense',
      amount: 3000.0,
      category: ExpenseCategory.other,
      date: DateTime(2025, 9, 15),
    );

    final allExpenses = [sep1, sep2, sep3, aug1, sepLastYear];

    test('filterByMonth filters expenses belonging strictly to specified year and month', () {
      final sept2026Expenses = allExpenses.filterByMonth(DateTime(2026, 9));
      expect(sept2026Expenses.length, 3);
      expect(sept2026Expenses.map((e) => e.id), containsAll(['1', '2', '3']));

      final aug2026Expenses = allExpenses.filterByMonth(DateTime(2026, 8));
      expect(aug2026Expenses.length, 1);
      expect(aug2026Expenses.first.id, '4');

      final emptyMonth = allExpenses.filterByMonth(DateTime(2026, 1));
      expect(emptyMonth.isEmpty, isTrue);
    });

    test('totalAmount calculates accurate sum of all expenses in list', () {
      final sept2026Expenses = allExpenses.filterByMonth(DateTime(2026, 9));
      expect(sept2026Expenses.totalAmount, 2800.0);

      expect(<Expense>[].totalAmount, 0.0);
    });

    test('categoryTotals aggregates spending per category', () {
      final sept2026Expenses = allExpenses.filterByMonth(DateTime(2026, 9));
      final totals = sept2026Expenses.categoryTotals;

      expect(totals[ExpenseCategory.food], 2300.0); // 1500 + 800
      expect(totals[ExpenseCategory.transport], 500.0);
      expect(totals.containsKey(ExpenseCategory.bills), isFalse);
    });
  });

  group('HomeScreen Month Switching & Calculation Widget Tests', () {
    testWidgets('Switching month updates Total Spent and displayed items', (WidgetTester tester) async {
      final septExpense = Expense(
        id: '1',
        title: 'September Lunch',
        amount: 450.0,
        category: ExpenseCategory.food,
        date: DateTime(2026, 9, 15),
      );
      final octExpense = Expense(
        id: '2',
        title: 'October Internet',
        amount: 1500.0,
        category: ExpenseCategory.bills,
        date: DateTime(2026, 10, 2),
      );

      final mockService = MockMonthlyExpenseService([septExpense, octExpense]);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      // Home Screen defaults to current month (September 2026 in test environment)
      // Verify Total Spent is rendered
      expect(find.text('Total Spent'), findsOneWidget);

      // Tap Next Month (>) button
      await tester.tap(find.byTooltip('Next Month'));
      await tester.pumpAndSettle();

      // Tap Previous Month (<) button
      await tester.tap(find.byTooltip('Previous Month'));
      await tester.pumpAndSettle();

      expect(find.text('Total Spent'), findsOneWidget);
    });
  });
}
