import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'Finense_Report.dart';
import 'Add_Transaction.dart';
import 'profile.dart';

class TransactionsHistory extends StatelessWidget {
  final String userId;

  TransactionsHistory({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Transactions History',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')  // Collection of users
              .doc(userId)  // Document of the current user
              .collection('transactions')  // Subcollection of transactions
              .orderBy('date', descending: true)  // Sort by date in descending order
              .snapshots(),  // Stream of real-time updates
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No transactions found.'));
            }

            var transactions = snapshot.data!.docs;

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                var transaction = transactions[index];
                Timestamp dateTimestamp = transaction['date'];
                DateTime date = dateTimestamp.toDate();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0), // Adds space between cards
                  child: TransactionCard(
                    date: '${date.month}/${date.day}/${date.year}',
                    type: transaction['transaction_type'] ?? 'Unknown',
                    amount: '\$${transaction['amount'].toString()}',
                    category: transaction['description'] ?? 'No description',
                    color: transaction['transaction_type'] == 'Income' ? Colors.green : Colors.red,
                    onDelete: () {
                      // Firestore delete logic
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('transactions')
                          .doc(transaction.id)
                          .delete()
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Transaction deleted successfully!'))
                        );
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting transaction: $error'))
                        );
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // This will be irrelevant since we navigate instead
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

class TransactionCard extends StatelessWidget {
  final String date;
  final String type;
  final String amount;
  final String category;
  final Color color;
  final VoidCallback onDelete; // Callback for delete functionality

  const TransactionCard({
    required this.date,
    required this.type,
    required this.amount,
    required this.category,
    required this.color,
    required this.onDelete, // Pass the onDelete callback
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue[900]!, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Left Section: Date, Type, and Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  type,
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  category,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          // Right Section: Amount and Trash Icon
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 8), // Space between amount and trash icon
              IconButton(
                icon: Icon(Icons.delete, color: Colors.black),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

