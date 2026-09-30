import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/expenses_screen.dart';
import 'package:spendly/services/expense_service.dart';
import 'package:spendly/widgets/empty_state.dart';

class MockSearchExpenseService extends ExpenseService {
  final List<Expense> expenses;

  MockSearchExpenseService(this.expenses);

  @override
  Stream<List<Expense>> getExpenses() {
    return Stream.value(expenses);
  }
}

void main() {
  group('ExpensesScreen Search Tests', () {
    final lunchExpense = Expense(
      id: '1',
      title: 'Business Lunch',
      amount: 850.0,
      category: ExpenseCategory.food,
      date: DateTime(2026, 9, 15),
      note: 'Meeting with client',
    );
    final groceryExpense = Expense(
      id: '2',
      title: 'Weekly Groceries',
      amount: 2200.0,
      category: ExpenseCategory.food,
      date: DateTime(2026, 9, 16),
      note: 'Vegetables and dairy',
    );
    final fuelExpense = Expense(
      id: '3',
      title: 'Car Fuel',
      amount: 1500.0,
      category: ExpenseCategory.transport,
      date: DateTime(2026, 9, 18),
      note: 'Petrol pump',
    );

    testWidgets('Searching by title filters matching expenses case-insensitively', (WidgetTester tester) async {
      final mockService = MockSearchExpenseService([
        lunchExpense,
        groceryExpense,
        fuelExpense,
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      // All 3 expenses visible initially
      expect(find.text('3 Total Records'), findsOneWidget);
      expect(find.text('Business Lunch'), findsOneWidget);
      expect(find.text('Weekly Groceries'), findsOneWidget);
      expect(find.text('Car Fuel'), findsOneWidget);

      // Enter lowercase 'lunch' in the search field
      await tester.enterText(find.byType(TextField), 'lunch');
      await tester.pumpAndSettle();

      // Only 'Business Lunch' should be displayed
      expect(find.text('1 Record (Filtered)'), findsOneWidget);
      expect(find.text('Business Lunch'), findsOneWidget);
      expect(find.text('Weekly Groceries'), findsNothing);
      expect(find.text('Car Fuel'), findsNothing);

      // Clear search via clear icon button in search bar
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();

      // All 3 items should reappear
      expect(find.text('3 Total Records'), findsOneWidget);
      expect(find.text('Business Lunch'), findsOneWidget);
      expect(find.text('Weekly Groceries'), findsOneWidget);
      expect(find.text('Car Fuel'), findsOneWidget);
    });

    testWidgets('Searching for non-existent expense displays empty search state', (WidgetTester tester) async {
      final mockService = MockSearchExpenseService([lunchExpense]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search for non-matching item
      await tester.enterText(find.byType(TextField), 'Flight Ticket');
      await tester.pumpAndSettle();

      expect(find.text('No matching expenses'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(EmptyState),
          matching: find.textContaining('Flight Ticket'),
        ),
        findsOneWidget,
      );
      expect(find.text('Clear Filters'), findsWidgets);
    });
  });
}
