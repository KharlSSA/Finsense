import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'Add_Transaction.dart';
import 'Finense_Report.dart';
import 'Transaction_History.dart';
import 'profile.dart';

class HomePage extends StatelessWidget {
  final String userId;
  final String? userName;

  HomePage({required this.userId, this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        toolbarHeight: 180,
        automaticallyImplyLeading: false,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                'Loading...',
                style: TextStyle(color: Colors.white),
              );
            }
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return Text(
                'Error loading user',
                style: TextStyle(color: Colors.white),
              );
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String userName = (userData['full_name'] != null && userData['full_name'].toString().trim().isNotEmpty)
                ? userData['full_name']
                : 'User';

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('transactions')
                  .snapshots(),
              builder: (context, txnSnapshot) {
                if (txnSnapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Loading transactions...',
                    style: TextStyle(color: Colors.white),
                  );
                }

                if (txnSnapshot.hasError || !txnSnapshot.hasData) {
                  return Text(
                    'Error loading transactions',
                    style: TextStyle(color: Colors.white),
                  );
                }

                var transactions = txnSnapshot.data!.docs;

                double totalIncome = transactions
                    .where((txn) => (txn.data() as Map<String, dynamic>)['transaction_type'] == 'Income')
                    .fold(0.0, (sum, txn) => sum + (txn.data() as Map<String, dynamic>)['amount']);

                double totalExpenses = transactions
                    .where((txn) => (txn.data() as Map<String, dynamic>)['transaction_type'] == 'Expense')
                    .fold(0.0, (sum, txn) => sum + (txn.data() as Map<String, dynamic>)['amount']);

                double totalBalance = totalIncome - totalExpenses;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out left and right content
                  crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
                  children: [
                    // Left side (FINSENSE and welcome message)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FINSENSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Welcome back, $userName!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    // Right side (Total Balance)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end, // Align text to the right
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '\$${totalBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: HomeContent(userId: userId),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
}

class HomeContent extends StatelessWidget {
  final String userId;

  HomeContent({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error loading transactions'));
        }

        var transactions = snapshot.data!.docs;

        double totalIncome = transactions
            .where((txn) => (txn.data() as Map<String, dynamic>)['transaction_type'] == 'Income')
            .fold(0.0, (sum, txn) => sum + (txn.data() as Map<String, dynamic>)['amount']);

        double totalExpenses = transactions
            .where((txn) => (txn.data() as Map<String, dynamic>)['transaction_type'] == 'Expense')
            .fold(0.0, (sum, txn) => sum + (txn.data() as Map<String, dynamic>)['amount']);

        double totalBalance = totalIncome - totalExpenses;

        String formattedDate(Timestamp timestamp) {
          DateTime dateTime = timestamp.toDate();
          return DateFormat('yMMMd').format(dateTime);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCard('Income', '\$${totalIncome.toStringAsFixed(2)}', Colors.green),
                    _buildCard('Expenses', '\$${totalExpenses.toStringAsFixed(2)}', Colors.red),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionsHistory(userId: userId),
                              ),
                            );
                          },
                          child: Text('See All', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ...transactions.map((txn) {
                      var txnData = txn.data() as Map<String, dynamic>;
                      return _buildTransaction(
                        txnData['description'] ?? 'No Description',
                        formattedDate(txnData['date']),
                        '\$${txnData['amount']?.toStringAsFixed(2) ?? '0.00'}',
                        txnData['transaction_type'] == 'Income' ? Colors.green : Colors.red,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(
              title == 'Income'
                  ? Icons.arrow_upward
                  : title == 'Expenses'
                  ? Icons.arrow_downward
                  : Icons.account_balance_wallet,
              color: color,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransaction(String title, String date, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
