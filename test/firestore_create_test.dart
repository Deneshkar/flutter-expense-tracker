import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/add_expense_screen.dart';
import 'package:spendly/services/expense_service.dart';

/// Test implementation of ExpenseService to verify Create behavior
class MockCreateExpenseService extends ExpenseService {
  Expense? lastAddedExpense;
  bool shouldThrowError = false;

  @override
  Future<void> addExpense(Expense expense) async {
    if (shouldThrowError) {
      throw Exception('Simulated network error');
    }
    // Simulate Firestore auto-generating an ID
    lastAddedExpense = expense.copyWith(id: 'mock_doc_id_123');
  }
}

void main() {
  group('Firestore Create (Add Expense) Tests', () {
    testWidgets('AddExpenseScreen creates and saves expense with all required fields', (WidgetTester tester) async {
      final mockService = MockCreateExpenseService();

      await tester.pumpWidget(
        MaterialApp(
          home: AddExpenseScreen(expenseService: mockService),
        ),
      );

      // Enter title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Expense Title *'),
        'Dinner at Bistro',
      );

      // Enter amount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount (Rs.) *'),
        '1450',
      );

      // Enter note
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Note (Optional)'),
        'Dinner with friends',
      );

      // Tap Save
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      // Verify the service received the expense
      expect(mockService.lastAddedExpense, isNotNull);
      expect(mockService.lastAddedExpense!.title, 'Dinner at Bistro');
      expect(mockService.lastAddedExpense!.amount, 1450.0);
      expect(mockService.lastAddedExpense!.category, ExpenseCategory.food);
      expect(mockService.lastAddedExpense!.note, 'Dinner with friends');
      expect(mockService.lastAddedExpense!.id, 'mock_doc_id_123');

      // Verify toMap contains all 7 required Firestore fields
      final map = mockService.lastAddedExpense!.toMap();
      expect(map.containsKey('id'), isTrue);
      expect(map.containsKey('title'), isTrue);
      expect(map.containsKey('amount'), isTrue);
      expect(map.containsKey('category'), isTrue);
      expect(map.containsKey('date'), isTrue);
      expect(map.containsKey('note'), isTrue);
      expect(map.containsKey('createdAt'), isTrue);
    });

    testWidgets('AddExpenseScreen shows error SnackBar on failure', (WidgetTester tester) async {
      final mockService = MockCreateExpenseService()..shouldThrowError = true;

      await tester.pumpWidget(
        MaterialApp(
          home: AddExpenseScreen(expenseService: mockService),
        ),
      );

      // Enter valid fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Expense Title *'),
        'Taxi Fare',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount (Rs.) *'),
        '300',
      );

      // Tap Save
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      // Expect a user-friendly error message, not technical stacktrace
      expect(
        find.text('Failed to save expense. Please try again.'),
        findsOneWidget,
      );
    });
  });
}
