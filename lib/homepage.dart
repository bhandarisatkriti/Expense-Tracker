import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_1/screens/add_expense.dart';
import 'package:project_1/screens/chart.dart';
import 'package:project_1/screens/history_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> transactions = [];
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    openBoxAndLoadTransactions();
  }

  Future<void> openBoxAndLoadTransactions() async {
    await Hive.openBox('transactions');
    loadTransactions();
  }

  void loadTransactions() {
    var box = Hive.box('transactions');
    setState(() {
      transactions = box.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    });
  }

  // Delete transaction and log history
  void deleteTransaction(int index) async {
    var box = Hive.box('transactions');
    var deletedItem = Map<String, dynamic>.from(box.getAt(index));

    // Save delete action to history
    var historyBox = await Hive.openBox('historyBox');
    await historyBox.add({
      "action": "Deleted",
      "title": deletedItem["title"],
      "amount": deletedItem["amount"],
      "date": DateTime.now().toString(),
    });

    box.deleteAt(index);
    loadTransactions();
  }

  double getTotalBalance() {
    double balance = 0;
    for (var tx in transactions) {
      balance += (tx["amount"] as double);
    }
    return balance;
  }

  double getIncome() {
    double income = 0;
    for (var tx in transactions) {
      double amount = tx["amount"] as double;
      if (amount > 0) income += amount;
    }
    return income;
  }

  double getExpense() {
    double expense = 0;
    for (var tx in transactions) {
      double amount = tx["amount"] as double;
      if (amount < 0) expense += amount;
    }
    return expense.abs();
  }

  double getMaxAmount() {
    if (transactions.isEmpty) return 0;
    return transactions
        .map((tx) => (tx['amount'] as double).abs())
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final maxAmount = getMaxAmount();

    Widget bodyWidget;

    if (_selectedIndex == 0) {
      bodyWidget = Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpenseChart(
          recentTransactions: transactions,
          maxAmount: maxAmount,
        ),
      );
    } else {
      bodyWidget = Column(
        children: [
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF5E35B1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  "Total Balance",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  "\$${getTotalBalance().toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          "Income\n\$${getIncome().toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          "Expense\n\$${getExpense().toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Transactions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("No transactions yet"))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            (tx["amount"] as double) > 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: (tx["amount"] as double) > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(tx["title"] ?? ''),
                          subtitle: Text(tx["date"] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "\$${(tx["amount"] as double).toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: (tx["amount"] as double) > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteTransaction(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(widget.username),
                accountEmail: null,
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey[700],
                  ),
                ),
                decoration: const BoxDecoration(color: Color(0xFF5E35B1)),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                subtitle: Text(widget.username),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('History'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Welcome, ${widget.username}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5E35B1),
      ),
      body: bodyWidget,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5E35B1),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );
          loadTransactions();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        elevation: 10,
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 248, 247, 247).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 1 ? Colors.deepPurple : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.bar_chart,
                  color: _selectedIndex == 0 ? Colors.deepPurple : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
