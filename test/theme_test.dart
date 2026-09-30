import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendly/main.dart';
import 'package:spendly/models/expense.dart';
import 'package:spendly/screens/expenses_screen.dart';
import 'package:spendly/services/expense_service.dart';
import 'package:spendly/theme/app_theme.dart';

class MockThemeExpenseService extends ExpenseService {
  final List<Expense> expenses;

  MockThemeExpenseService([this.expenses = const []]);

  @override
  Stream<List<Expense>> getExpenses() {
    return Stream.value(expenses);
  }
}

void main() {
  setUp(() {
    // Reset themeNotifier to light mode before each test
    AppTheme.themeNotifier.value = ThemeMode.light;
  });

  group('Step 16: AppTheme Unit Tests', () {
    test('themeNotifier toggles correctly between light and dark', () {
      expect(AppTheme.themeNotifier.value, ThemeMode.light);

      AppTheme.toggleTheme();
      expect(AppTheme.themeNotifier.value, ThemeMode.dark);

      AppTheme.toggleTheme();
      expect(AppTheme.themeNotifier.value, ThemeMode.light);
    });

    test('lightTheme has light brightness and correct color tokens', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppTheme.primaryColor);
      expect(theme.scaffoldBackgroundColor, AppTheme.surfaceLight);
    });

    test('darkTheme has dark brightness and deep slate background', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppTheme.primaryDark);
      expect(theme.scaffoldBackgroundColor, AppTheme.surfaceDark);
    });
  });

  group('Step 16: Theme Toggle Widget Tests', () {
    testWidgets('HomeScreen theme toggle button switches theme mode', (WidgetTester tester) async {
      final customNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
      final mockService = MockThemeExpenseService();

      await tester.pumpWidget(
        SpendlyApp(
          expenseService: mockService,
          themeNotifier: customNotifier,
        ),
      );
      await tester.pumpAndSettle();

      // Initially in light mode - button tooltip indicates switch to dark mode
      expect(find.byTooltip('Switch to Dark Mode'), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

      // Tap theme toggle button
      await tester.tap(find.byTooltip('Switch to Dark Mode'));
      await tester.pumpAndSettle();

      // ValueNotifier should now be dark
      expect(customNotifier.value, ThemeMode.dark);

      // In dark mode - button tooltip indicates switch to light mode
      expect(find.byTooltip('Switch to Light Mode'), findsOneWidget);
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

      // Tap again to switch back
      await tester.tap(find.byTooltip('Switch to Light Mode'));
      await tester.pumpAndSettle();

      expect(customNotifier.value, ThemeMode.light);
    });

    testWidgets('ExpensesScreen includes theme toggle button in AppBar', (WidgetTester tester) async {
      bool toggleCalled = false;
      final mockService = MockThemeExpenseService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExpensesScreen(
            expenseService: mockService,
            onToggleTheme: () {
              toggleCalled = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Switch to Dark Mode'), findsOneWidget);
      await tester.tap(find.byTooltip('Switch to Dark Mode'));
      expect(toggleCalled, isTrue);
    });
  });
}
