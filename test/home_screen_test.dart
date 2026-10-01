import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/home_screen.dart';
import 'package:spendly/services/expense_service.dart';

class MockHomeExpenseService extends ExpenseService {
  final List<Expense> expenses;
  String? deletedExpenseId;

  MockHomeExpenseService(this.expenses);

  @override
  Stream<List<Expense>> getExpenses() {
    return Stream.value(expenses);
  }

  @override
  Future<void> deleteExpense(String id) async {
    deletedExpenseId = id;
  }
}

void main() {
  group('HomeScreen Interactive Tests', () {
    testWidgets('Tapping FAB invokes onNavigateToAddExpense callback', (WidgetTester tester) async {
      bool addNavigated = false;
      final mockService = MockHomeExpenseService([]);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            expenseService: mockService,
            onNavigateToAddExpense: () {
              addNavigated = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Expense').last);
      expect(addNavigated, isTrue);
    });

    testWidgets('Tapping history icon invokes onNavigateToExpenses callback', (WidgetTester tester) async {
      bool expensesNavigated = false;
      final mockService = MockHomeExpenseService([]);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            expenseService: mockService,
            onNavigateToExpenses: () {
              expensesNavigated = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('All Expenses'));
      expect(expensesNavigated, isTrue);
    });

    testWidgets('Tapping expense item invokes onEditExpense callback', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Expense? editedExpense;
      final now = DateTime.now();
      final testExpense = Expense(
        id: 'exp_1',
        title: 'Dinner',
        amount: 800,
        category: ExpenseCategory.food,
        date: DateTime(now.year, now.month, 10),
      );

      final mockService = MockHomeExpenseService([testExpense]);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            expenseService: mockService,
            onEditExpense: (e) {
              editedExpense = e;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();

      expect(editedExpense, isNotNull);
      expect(editedExpense!.id, 'exp_1');
    });

    testWidgets('Tapping month selector opens date picker dialog', (WidgetTester tester) async {
      final mockService = MockHomeExpenseService([]);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.calendar_today_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('Shows "View All" and navigates when more than 5 expenses exist in month', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool viewAllTapped = false;
      final now = DateTime.now();
      final expenses = List.generate(
        7,
        (i) => Expense(
          id: 'exp_$i',
          title: 'Expense $i',
          amount: 100.0 * (i + 1),
          category: ExpenseCategory.food,
          date: DateTime(now.year, now.month, i + 1),
        ),
      );

      final mockService = MockHomeExpenseService(expenses);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            expenseService: mockService,
            onNavigateToExpenses: () {
              viewAllTapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('View All'), findsOneWidget);
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(viewAllTapped, isTrue);
    });
  });
}
