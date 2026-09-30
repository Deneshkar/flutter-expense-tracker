import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

/// Screen displaying the complete history of all recorded expenses
/// with category and date filtering options.
class ExpensesScreen extends StatefulWidget {
  final ExpenseService? expenseService;
  final Function(Expense)? onEditExpense;

  const ExpensesScreen({
    super.key,
    this.expenseService,
    this.onEditExpense,
  });

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late final ExpenseService _expenseService;

  // Active filters
  String _selectedCategory = 'All';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _expenseService = widget.expenseService ?? ExpenseService();
  }

  /// Opens the Add Expense screen.
  void _navigateToAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expenseService: _expenseService),
      ),
    );
  }

  /// Opens the Edit Expense screen.
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

  /// Opens date picker to filter expenses by a specific date.
  Future<void> _pickDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Filter by Date',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Resets all active filters to default (All categories, no date filter).
  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedDate = null;
    });
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
    final hasActiveFilter =
        _selectedCategory != 'All' || _selectedDate != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        actions: [
          if (hasActiveFilter)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all_rounded, size: 18),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unable to load your expenses.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allExpenses = snapshot.data ?? [];

          // 3. Apply Category and Date Filters
          var filteredExpenses = allExpenses;

          if (_selectedCategory != 'All') {
            filteredExpenses = filteredExpenses
                .where((e) => e.category == _selectedCategory)
                .toList();
          }

          if (_selectedDate != null) {
            filteredExpenses = filteredExpenses.where((e) {
              return e.date.year == _selectedDate!.year &&
                  e.date.month == _selectedDate!.month &&
                  e.date.day == _selectedDate!.day;
            }).toList();
          }

          // 4. Calculate total sum of filtered list
          final double totalSpent = filteredExpenses.totalAmount;

          return Column(
            children: [
              // A. Filter Controls Bar
              _buildFilterBar(),

              // B. Expenses List, Filtered Results, or Empty States
              Expanded(
                child: allExpenses.isEmpty
                    ? EmptyState(
                        title: 'No expenses yet',
                        message:
                            'Start tracking your spending\nby adding your first expense.',
                        buttonText: 'Add Expense',
                        onButtonPressed: _navigateToAddExpense,
                      )
                    : filteredExpenses.isEmpty
                        ? EmptyState(
                            title: 'No matching expenses',
                            message:
                                'No expenses found for the selected filter.\nTry clearing or adjusting filters.',
                            icon: Icons.filter_alt_off_rounded,
                            buttonText: 'Clear Filters',
                            onButtonPressed: _clearFilters,
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            children: [
                              // Summary Banner
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      hasActiveFilter
                                          ? '${filteredExpenses.length} ${filteredExpenses.length == 1 ? 'Record' : 'Records'} (Filtered)'
                                          : '${filteredExpenses.length} Total Records',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      ExpenseCard.formatAmount(totalSpent),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Render items with swipe-to-delete
                              ...filteredExpenses.map(
                                (expense) => Dismissible(
                                  key: Key('history_${expense.id}'),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (_) =>
                                      _confirmDelete(expense),
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
                                    onTap: () =>
                                        _navigateToEditExpense(expense),
                                    onEdit: () =>
                                        _navigateToEditExpense(expense),
                                    onDelete: () => _confirmDelete(expense),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        tooltip: 'Add Expense',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  /// Horizontal category filter chips and date selector bar.
  Widget _buildFilterBar() {
    final categories = ['All', ...ExpenseCategory.all];
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Horizontal Category Filter Chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;
                final color = category == 'All'
                    ? const Color(0xFF2563EB)
                    : ExpenseCategory.getColor(category);
                final icon = category == 'All'
                    ? Icons.grid_view_rounded
                    : ExpenseCategory.getIcon(category);

                return FilterChip(
                  avatar: Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                  label: Text(category),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF0F172A),
                  ),
                  selected: isSelected,
                  selectedColor: color,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide(
                    color: isSelected ? color : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // 2. Date Filter and Clear Filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ActionChip(
                  avatar: Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: _selectedDate != null
                        ? const Color(0xFF2563EB)
                        : Colors.grey.shade600,
                  ),
                  label: Text(
                    _selectedDate != null
                        ? dateFormat.format(_selectedDate!)
                        : 'Filter by Date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _selectedDate != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedDate != null
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  backgroundColor: _selectedDate != null
                      ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  side: BorderSide(
                    color: _selectedDate != null
                        ? const Color(0xFF2563EB)
                        : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onPressed: _pickDateFilter,
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (_selectedCategory != 'All' || _selectedDate != null)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_rounded, size: 14),
                    label: const Text('Clear Filters',
                        style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
