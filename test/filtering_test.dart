import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/expenses_screen.dart';
import 'package:spendly/services/expense_service.dart';

class MockFilterExpenseService extends ExpenseService {
  final List<Expense> expenses;

  MockFilterExpenseService(this.expenses);

  @override
  Stream<List<Expense>> getExpenses() {
    return Stream.value(expenses);
  }
}

void main() {
  group('ExpensesScreen Filtering Tests', () {
    final foodExpense = Expense(
      id: '1',
      title: 'Lunch',
      amount: 450.0,
      category: ExpenseCategory.food,
      date: DateTime(2026, 9, 15),
    );
    final transportExpense = Expense(
      id: '2',
      title: 'Bus Ticket',
      amount: 150.0,
      category: ExpenseCategory.transport,
      date: DateTime(2026, 9, 15),
    );
    final shoppingExpense = Expense(
      id: '3',
      title: 'Shoes',
      amount: 2500.0,
      category: ExpenseCategory.shopping,
      date: DateTime(2026, 9, 20),
    );

    testWidgets('Filtering by category updates list and summary banner', (WidgetTester tester) async {
      final mockService = MockFilterExpenseService([
        foodExpense,
        transportExpense,
        shoppingExpense,
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      // Initially all 3 expenses are visible
      expect(find.text('3 Total Records'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Bus Ticket'), findsOneWidget);
      expect(find.text('Shoes'), findsOneWidget);

      // Tap 'Food' filter chip
      await tester.tap(find.widgetWithText(FilterChip, 'Food'));
      await tester.pumpAndSettle();

      // Now only Food expense is visible
      expect(find.text('1 Record (Filtered)'), findsOneWidget);
      expect(find.text('Rs. 450'), findsNWidgets(2)); // Once in summary banner, once on ExpenseCard
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Bus Ticket'), findsNothing);
      expect(find.text('Shoes'), findsNothing);

      // Tap 'Clear Filters' button
      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      // All expenses restored
      expect(find.text('3 Total Records'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Bus Ticket'), findsOneWidget);
    });

    testWidgets('Shows empty filter state when no items match category', (WidgetTester tester) async {
      final mockService = MockFilterExpenseService([foodExpense]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Bills' which has no items
      await tester.tap(find.widgetWithText(FilterChip, 'Bills'));
      await tester.pumpAndSettle();

      expect(find.text('No matching expenses'), findsOneWidget);
      expect(find.text('Clear Filters'), findsWidgets);
    });
  });
}
