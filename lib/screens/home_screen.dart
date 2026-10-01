import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/expense_card.dart';
import '../widgets/loading_state.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';
import 'expenses_screen.dart';

/// The primary Home Screen of Spendly.
///
/// Displays:
/// - Current or selected month selector
/// - Total expenses spent in that month
/// - Quick category spending breakdown
/// - List of recent expenses for that month
/// - Quick action to add a new expense
class HomeScreen extends StatefulWidget {
  final ExpenseService? expenseService;
  final VoidCallback? onNavigateToExpenses;
  final VoidCallback? onNavigateToAddExpense;
  final Function(Expense)? onEditExpense;
  final VoidCallback? onToggleTheme;

  const HomeScreen({
    super.key,
    this.expenseService,
    this.onNavigateToExpenses,
    this.onNavigateToAddExpense,
    this.onEditExpense,
    this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ExpenseService _expenseService;
  late Stream<List<Expense>> _expensesStream;

  // Selected month for viewing expense records
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _expenseService = widget.expenseService ?? ExpenseService();
    _expensesStream = _expenseService.getExpenses();
    // Default to the first day of the current month
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  /// Retries fetching expenses when an error occurs.
  void _retry() {
    setState(() {
      _expensesStream = _expenseService.getExpenses();
    });
  }

  /// Changes the selected month backwards by 1 month.
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  /// Changes the selected month forward by 1 month.
  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  /// Opens a date picker dialog to pick any month/year directly.
  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Select Month',
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  /// Navigates to the Add Expense screen.
  void _navigateToAddExpense() {
    if (widget.onNavigateToAddExpense != null) {
      widget.onNavigateToAddExpense!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddExpenseScreen(expenseService: _expenseService),
        ),
      );
    }
  }

  /// Navigates to the All Expenses history screen.
  void _navigateToExpenses() {
    if (widget.onNavigateToExpenses != null) {
      widget.onNavigateToExpenses!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExpensesScreen(expenseService: _expenseService),
        ),
      );
    }
  }

  /// Navigates to the Edit Expense screen.
  void _navigateToEditExpense(Expense expense) {
    if (widget.onEditExpense != null) {
      widget.onEditExpense!(expense);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditExpenseScreen(
            expense: expense,
            expenseService: _expenseService,
          ),
        ),
      );
    }
  }

  /// Shows confirmation dialog before deleting an expense.
  Future<bool> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Expense?'),
        content: Text(
          'Are you sure you want to delete "${expense.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _expenseService.deleteExpense(expense.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${expense.title}"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete expense. Please try again.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy');
    final formattedMonth = monthFormat.format(_selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.wallet_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Spendly',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: Theme.of(context).brightness == Brightness.dark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: widget.onToggleTheme ?? AppTheme.toggleTheme,
          ),
          IconButton(
            tooltip: 'All Expenses',
            icon: const Icon(Icons.history_rounded),
            onPressed: _navigateToExpenses,
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _expensesStream,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const LoadingState(message: 'Loading your expenses...');
          }

          // 2. Error State
          if (snapshot.hasError) {
            return ErrorState(
              message:
                  'Unable to load your expenses. Please check your connection and try again.',
              onRetry: _retry,
            );
          }

          final allExpenses = snapshot.data ?? [];

          // 3. Filter expenses for the selected month
          final monthExpenses = allExpenses.filterByMonth(_selectedMonth);

          // 4. Calculate total spent in the selected month
          final double totalSpent = monthExpenses.totalAmount;

          // 5. Calculate category spending summary for the selected month
          final Map<String, double> categoryBreakdown =
              monthExpenses.categoryTotals;

          // Recent expenses (up to 5 most recent)
          final recentExpenses = monthExpenses.take(5).toList();

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    // A. Month Selector Bar
                    _buildMonthSelector(formattedMonth),
                    const SizedBox(height: 16),

                // B. Total Spent Card
                _buildTotalSpentCard(totalSpent, monthExpenses.length),
                const SizedBox(height: 20),

                // C. Category Expense Chart (if expenses exist in this month)
                if (categoryBreakdown.isNotEmpty) ...[
                  CategoryChart(
                    categoryTotals: categoryBreakdown,
                    totalSpent: totalSpent,
                  ),
                  const SizedBox(height: 24),
                ],

                // D. Recent Expenses Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Expenses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (monthExpenses.length > 5)
                      TextButton(
                        onPressed: _navigateToExpenses,
                        child: const Text('View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // E. Expense List or Empty State
                if (monthExpenses.isEmpty)
                  EmptyState(
                    title: 'No expenses for $formattedMonth',
                    message:
                        'Start tracking your spending\nby adding your first expense.',
                    buttonText: 'Add Expense',
                    onButtonPressed: _navigateToAddExpense,
                  )
                else
                  ...recentExpenses.map(
                    (expense) => Dismissible(
                      key: Key('home_${expense.id}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(expense),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: ExpenseCard(
                        expense: expense,
                        onTap: () => _navigateToEditExpense(expense),
                        onEdit: () => _navigateToEditExpense(expense),
                        onDelete: () => _confirmDelete(expense),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddExpense,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Month selector with previous/next buttons and clickable month title.
  Widget _buildMonthSelector(String formattedMonth) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous Month',
            onPressed: _previousMonth,
          ),
          Flexible(
            child: InkWell(
              onTap: _pickMonth,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        formattedMonth,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next Month',
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  /// Highlight card displaying the total expenses spent in the selected month.
  Widget _buildTotalSpentCard(double totalSpent, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Total Spent',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count ${count == 1 ? 'transaction' : 'transactions'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              ExpenseCard.formatAmount(totalSpent),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


