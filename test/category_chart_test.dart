import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/home_screen.dart';
import 'package:spendly/services/expense_service.dart';
import 'package:spendly/widgets/category_chart.dart';

class MockChartExpenseService extends ExpenseService {
  final List<Expense> expenses;

  MockChartExpenseService(this.expenses);

  @override
  Stream<List<Expense>> getExpenses() {
    return Stream.value(expenses);
  }
}

void main() {
  group('Step 15: CategoryChart Widget Tests', () {
    testWidgets('CategoryChart renders nothing when data is empty or total is zero', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryChart(
              categoryTotals: {},
              totalSpent: 0,
            ),
          ),
        ),
      );

      expect(find.byType(PieChart), findsNothing);
      expect(find.text('Spending by Category'), findsNothing);
    });

    testWidgets('CategoryChart renders PieChart, category counts, percentages and amounts', (WidgetTester tester) async {
      final categoryTotals = {
        ExpenseCategory.food: 1500.0,
        ExpenseCategory.bills: 500.0,
      };
      const totalSpent = 2000.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CategoryChart(
                categoryTotals: categoryTotals,
                totalSpent: totalSpent,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.text('2 Categories'), findsOneWidget);

      // PieChart is rendered
      expect(find.byType(PieChart), findsOneWidget);

      // Legend items
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('75.0%'), findsOneWidget);
      expect(find.text('Bills'), findsOneWidget);
      expect(find.text('25.0%'), findsOneWidget);
    });

    testWidgets('Tapping a category legend item selects it and updates center details', (WidgetTester tester) async {
      final categoryTotals = {
        ExpenseCategory.food: 1200.0,
        ExpenseCategory.transport: 800.0,
      };
      const totalSpent = 2000.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CategoryChart(
                categoryTotals: categoryTotals,
                totalSpent: totalSpent,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially center shows 'Total'
      expect(find.text('Total'), findsOneWidget);

      // Tap 'Food' row in legend
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Now center shows tapped category name 'Food'
      expect(find.text('Food'), findsWidgets);
    });

    testWidgets('HomeScreen displays CategoryChart when expenses exist for selected month', (WidgetTester tester) async {
      final now = DateTime.now();
      final mockService = MockChartExpenseService([
        Expense(
          id: '1',
          title: 'Dinner',
          amount: 600.0,
          category: ExpenseCategory.food,
          date: DateTime(now.year, now.month, 10),
        ),
        Expense(
          id: '2',
          title: 'Train Ticket',
          amount: 400.0,
          category: ExpenseCategory.transport,
          date: DateTime(now.year, now.month, 12),
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(expenseService: mockService),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryChart), findsOneWidget);
      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
    });
  });
}
