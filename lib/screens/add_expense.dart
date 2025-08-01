import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  double? amount;
  DateTime selectedDate = DateTime.now();
  bool isIncome = true; // true = income, false = expense

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final transaction = {
      'title': title,
      'amount': isIncome ? amount : -amount!, // Negative for expense
      'date':
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
    };

    final box = Hive.box('transactions');
    await box.add(transaction);

    // Save to history box for tracking added transactions
    final historyBox = Hive.box('historyBox');
    await historyBox.add({
      'title': title,
      'amount': isIncome ? amount! : -amount!,
      'date': DateTime.now().toIso8601String(),
      'action': 'Added',
    });

    Navigator.pop(context); // Return to home after adding
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: const Color(0xFF5E35B1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title Input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Please enter title' : null,
                onSaved: (val) => title = val!.trim(),
              ),
              const SizedBox(height: 16),

              // Amount Input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive number';
                  }
                  return null;
                },
                onSaved: (val) => amount = double.parse(val!),
              ),
              const SizedBox(height: 16),

              // Date picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Select Date'),
                  )
                ],
              ),

              const SizedBox(height: 16),

              // Income / Expense toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Income'),
                    selected: isIncome,
                    selectedColor: Colors.green[300],
                    onSelected: (selected) {
                      if (selected) setState(() => isIncome = true);
                    },
                  ),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Expense'),
                    selected: !isIncome,
                    selectedColor: Colors.red[300],
                    onSelected: (selected) {
                      if (selected) setState(() => isIncome = false);
                    },
                  ),
                ],
              ),

              const Spacer(),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1), // button color
                    foregroundColor: Colors.white, // text/icon color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _saveTransaction,
                  child: const Text(
                    'Add Transaction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
