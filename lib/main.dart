import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'services/expense_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Ensure Flutter engine bindings are initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase native platform app
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const SpendlyApp());
}

class SpendlyApp extends StatelessWidget {
  final ExpenseService? expenseService;
  final ValueNotifier<ThemeMode>? themeNotifier;

  const SpendlyApp({
    super.key,
    this.expenseService,
    this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = themeNotifier ?? AppTheme.themeNotifier;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: notifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Spendly — Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: HomeScreen(
            expenseService: expenseService,
            onToggleTheme: () {
              notifier.value = notifier.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        );
      },
    );
  }
}
