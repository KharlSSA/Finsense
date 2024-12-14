import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'Finense_Report.dart';
import 'Transaction_History.dart';
import 'profile.dart';

void main() => runApp(FinenseTrackerApp());

class FinenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FinanceTrackerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FinanceTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Wrap body content inside a scroll view
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image at the top (logo size)
            Image.asset(
              'assets/finsense-logo.png', // Replace with your logo's path
              height: 50, // Adjust height for the logo size
              width:
                  50, // Adjust width if necessary, or set to null to keep it proportional
              fit: BoxFit.contain, // Ensures the logo retains its aspect ratio
            ),
            SizedBox(height: 20), // Adjust spacing between image and text

            // "Track Finances" text
            Text(
              'Track Finances',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 25),
            buildLabelField('Date:', 'Nov.18', readOnly: true),
            SizedBox(height: 20),
            buildLabelField('Type of Transaction:', 'Select Transaction',
                isDropdown: true),
            SizedBox(height: 20),
            buildLabelField('Enter Amount:', 'Amount'),
            SizedBox(height: 20),
            buildLabelField('Enter Description:', 'Description'),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Add transaction logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'ADD TRANSACTION',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FinanceTrackerScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FinancialSummaryApp()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TransactionsHistory()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileApp()),
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

  Widget buildLabelField(String label, String placeholder,
      {bool isDropdown = false, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        isDropdown
            ? DropdownButtonFormField<String>(
                items: [
                  DropdownMenuItem(
                      value: 'Transaction', child: Text('Transaction')),
                  DropdownMenuItem(value: 'Income', child: Text('Income')),
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                ],
                onChanged: (value) {},
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : TextField(
                readOnly: readOnly,
                keyboardType:
                    placeholder == 'Amount' ? TextInputType.number : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: placeholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
      ],
    );
  }
}
