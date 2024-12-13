import 'package:flutter/material.dart';

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Text(
                'Example',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey, size: 14),
              SizedBox(width: 5),
              Text(
                'Row',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          centerTitle: false,
          leading: SizedBox(), // No leading widget
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track Finances',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 20),
            buildLabelField('Date:', 'Current Date'),
            SizedBox(height: 15),
            buildLabelField('Type of Transaction:', 'Type of Transaction',
                isDropdown: true),
            SizedBox(height: 15),
            buildLabelField('Enter Amount:', 'Amount'),
            SizedBox(height: 15),
            buildLabelField('Enter Amount:', 'Amount'),
            SizedBox(height: 30),
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
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu, color: Colors.blue[900]),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.grey),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate, color: Colors.grey),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey),
            label: '',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget buildLabelField(String label, String placeholder, {bool isDropdown = false}) {
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
                  DropdownMenuItem(value: 'Transaction', child: Text('Transaction')),
                  DropdownMenuItem(value: 'Income', child: Text('Income')),
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                ],
                onChanged: (value) {},
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : TextField(
                readOnly: placeholder == 'Current Date',
                keyboardType:
                    placeholder == 'Amount' ? TextInputType.number : null,
                decoration: InputDecoration(
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
