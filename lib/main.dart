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

  const SpendlyApp({super.key, this.expenseService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spendly — Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeScreen(expenseService: expenseService),
    );
  }
}
