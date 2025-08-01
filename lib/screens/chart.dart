import 'package:flutter/material.dart';

class ExpenseChart extends StatelessWidget {
  final List<Map<String, dynamic>> recentTransactions; // Changed here
  final double maxAmount;

  const ExpenseChart({
    super.key,
    required this.recentTransactions,
    required this.maxAmount,
  });

  List<Map<String, Object>> get groupedTransactionValues {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(Duration(days: index));
      double totalSum = 0;

      for (var tx in recentTransactions) {
        DateTime txDate = DateTime.parse(tx["date"] as String);
        if (txDate.day == weekDay.day &&
            txDate.month == weekDay.month &&
            txDate.year == weekDay.year) {
          totalSum += (tx["amount"] as double).abs();
        }
      }

      return {
        'day': ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][weekDay.weekday % 7],
        'amount': totalSum,
      };
    }).reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: groupedTransactionValues.map((data) {
            final double amount = data['amount'] as double;
            final double barHeight = maxAmount == 0 ? 0 : (amount / maxAmount) * 100;

            return Flexible(
              fit: FlexFit.tight,
              child: Column(
                children: [
                  FittedBox(child: Text('\$${amount.toStringAsFixed(0)}')),
                  const SizedBox(height: 4),
                  Container(
                    height: barHeight,
                    width: 10,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(data['day'] as String),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
