import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    var historyBox = await Hive.openBox('historyBox');
    setState(() {
      history = historyBox.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
          .reversed // show latest first
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: const Color(0xFF5E35B1),
      ),
      body: history.isEmpty
          ? const Center(
              child: Text("No history yet"),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final isAdd = item["action"] == "Added";

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      isAdd ? Icons.add_circle : Icons.remove_circle,
                      color: isAdd ? Colors.green : Colors.red,
                    ),
                    title: Text(item["title"] ?? ''),
                    subtitle: Text(
                        "${item["action"]} on ${item["date"].toString().split('.')[0]}"),
                    trailing: Text(
                      "\$${(item["amount"] as double).toStringAsFixed(2)}",
                      style: TextStyle(
                        color: (item["amount"] as double) > 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
