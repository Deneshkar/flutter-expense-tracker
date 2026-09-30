import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

/// A reusable form widget for both adding and editing expenses.
class ExpenseForm extends StatefulWidget {
  final Expense? initialExpense;
  final Future<void> Function(Expense expense) onSave;
  final String submitButtonText;

  const ExpenseForm({
    super.key,
    this.initialExpense,
    required this.onSave,
    this.submitButtonText = 'Save Expense',
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;

    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense != null ? expense.amount.toString() : '',
    );
    _noteController = TextEditingController(text: expense?.note ?? '');

    _selectedCategory = expense?.category ?? ExpenseCategory.food;
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Opens the native date picker dialog to select an expense date.
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Expense Date',
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Validates the form and submits the expense.
  Future<void> _submitForm() async {
    // 1. Validate Form Fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final double amount = double.parse(_amountController.text.trim());

      final expense = Expense(
        id: widget.initialExpense?.id ?? '',
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim(),
        createdAt: widget.initialExpense?.createdAt ?? DateTime.now(),
      );

      await widget.onSave(expense);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save expense. Please try again.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Title Field
          TextFormField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Expense Title *',
              hintText: 'e.g. Grocery Shopping, Lunch',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an expense title';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 2. Amount Field
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (Rs.) *',
              hintText: '0.00',
              prefixIcon: Icon(Icons.currency_rupee_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an amount';
              }
              final parsed = double.tryParse(value.trim());
              if (parsed == null) {
                return 'Please enter a valid number';
              }
              if (parsed <= 0) {
                return 'Amount must be greater than 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 3. Category Selector Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category *',
              prefixIcon: Icon(Icons.category_rounded),
            ),
            items: ExpenseCategory.all.map((category) {
              final color = ExpenseCategory.getColor(category);
              final icon = ExpenseCategory.getIcon(category);
              return DropdownMenuItem<String>(
                value: category,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedCategory = val;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // 4. Date Picker Input Tile
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date *',
                prefixIcon: Icon(Icons.calendar_today_rounded),
                suffixIcon: Icon(Icons.arrow_drop_down_rounded),
              ),
              child: Text(
                dateFormat.format(_selectedDate),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 5. Note Field (Optional)
          TextFormField(
            controller: _noteController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Note (Optional)',
              hintText: 'Add extra details or description...',
              prefixIcon: Icon(Icons.description_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),

          // 6. Submit Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submitForm,
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.submitButtonText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
