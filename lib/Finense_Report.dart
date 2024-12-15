import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'Add_Transaction.dart';
import 'Transaction_History.dart';
import 'profile.dart';

class FinancialSummaryApp extends StatelessWidget {
  final String userId;

  FinancialSummaryApp({required this.userId});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MonthlyOverviewScreen(userId: userId),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MonthlyOverviewScreen extends StatelessWidget {
  final String userId;

  MonthlyOverviewScreen({required this.userId});

  // Fetch transactions from Firestore
  Stream<Map<String, dynamic>> getMonthlySummary() {
    DateTime now = DateTime.now();

    // Start and end of the current month
    Timestamp startOfCurrentMonth = Timestamp.fromDate(DateTime(now.year, now.month, 1));

    // Start and end of the last month
    DateTime startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    DateTime endOfLastMonth = DateTime(now.year, now.month, 0); // Last day of last month
    Timestamp startOfLastMonthTS = Timestamp.fromDate(startOfLastMonth);
    Timestamp endOfLastMonthTS = Timestamp.fromDate(endOfLastMonth);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .snapshots()
        .map((snapshot) {
      double currentIncome = 0, currentExpenses = 0;
      double lastIncome = 0, lastExpenses = 0;

      for (var doc in snapshot.docs) {
        String transactionType = doc['transaction_type'] ?? '';
        double amount = doc['amount'] ?? 0.0;
        Timestamp date = doc['date'];

        // Current Month Calculation
        if (date.compareTo(startOfCurrentMonth) >= 0) {
          if (transactionType == 'Income') currentIncome += amount;
          if (transactionType == 'Expense') currentExpenses += amount;
        }

        // Last Month Calculation
        if (date.compareTo(startOfLastMonthTS) >= 0 && date.compareTo(endOfLastMonthTS) <= 0) {
          if (transactionType == 'Income') lastIncome += amount;
          if (transactionType == 'Expense') lastExpenses += amount;
        }
      }

      // Calculate Savings
      double currentSavings = currentIncome - currentExpenses;
      double lastSavings = lastIncome - lastExpenses;

      return {
        'currentIncome': currentIncome,
        'currentExpenses': currentExpenses,
        'currentSavings': currentSavings,
        'lastIncome': lastIncome,
        'lastExpenses': lastExpenses,
        'lastSavings': lastSavings,
      };
    });
  }

  String calculatePercentageChange(double current, double last) {
    if (last == 0) {
      if (current == 0) return 'No data for current month';
      return 'No data for last month';
    }

    double change = ((current - last) / last) * 100;
    return '${change.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Monthly Overview",
          style: TextStyle(
            fontWeight: FontWeight.w600, // Semi-bold weight
            color: Colors.blue[900], // Set text color to blue[900]
          ),
        ),
        backgroundColor: Colors.white, // Set background to white
        centerTitle: true, // Center the title
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<Map<String, dynamic>>(
          stream: getMonthlySummary(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return Center(child: Text('No transactions found.'));
            }

            final data = snapshot.data!;
            final currentIncome = data['currentIncome'] ?? 0.0;
            final currentExpenses = data['currentExpenses'] ?? 0.0;
            final currentSavings = data['currentSavings'] ?? 0.0;

            final lastIncome = data['lastIncome'] ?? 0.0;
            final lastExpenses = data['lastExpenses'] ?? 0.0;
            final lastSavings = data['lastSavings'] ?? 0.0;

            return Column(
              children: [
                buildSummaryCard(
                  title: 'Total Income',
                  value: '\$${currentIncome.toStringAsFixed(2)}',
                  change: calculatePercentageChange(currentIncome, lastIncome),
                  isPositive: currentIncome >= lastIncome,
                  subtitle: 'Current Month',
                ),
                SizedBox(height: 20),
                buildSummaryCard(
                  title: 'Total Expenses',
                  value: '\$${currentExpenses.toStringAsFixed(2)}',
                  change: calculatePercentageChange(currentExpenses, lastExpenses),
                  isPositive: currentExpenses < lastExpenses, // Less expenses is positive
                  subtitle: 'Current Month',
                ),
                SizedBox(height: 20),
                buildSummaryCard(
                  title: 'Total Savings',
                  value: '\$${currentSavings.toStringAsFixed(2)}',
                  change: calculatePercentageChange(currentSavings, lastSavings),
                  isPositive: currentSavings >= lastSavings,
                  subtitle: 'Current Month',
                  icon: Icons.savings,
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(userId: userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => FinenseTrackerApp(userId: userId)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => FinancialSummaryApp(userId: userId)),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TransactionsHistory(userId: userId)),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileApp(userId: userId)),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget buildSummaryCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required String subtitle,
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[900]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null)
                    Icon(icon, color: Colors.blue[900], size: 20),
                  if (icon != null) SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      SizedBox(height: 5),
                      Text(
                        value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'vs Last Month',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 5),
                  Text(
                    change,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: change == 'No data for current month' || change == 'No data for last month'
                          ? Colors.black // Set the color to black if no data
                          : isPositive
                          ? Colors.green // If positive, green
                          : Colors.red, // If negative, red
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
