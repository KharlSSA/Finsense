import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Finense_Report.dart';
import 'Transaction_History.dart';
import 'profile.dart';

class FinenseTrackerApp extends StatelessWidget {
  final String userId;

  FinenseTrackerApp({required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FinanceTrackerScreen(userId: userId),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FinanceTrackerScreen extends StatefulWidget {
  final String userId;

  FinanceTrackerScreen({required this.userId});

  @override
  _FinanceTrackerScreenState createState() => _FinanceTrackerScreenState();
}

class _FinanceTrackerScreenState extends State<FinanceTrackerScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _transactionType = 'Select transaction type'; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image at the top (logo size)
            Image.asset(
              'assets/finsense-logo.png', // Replace with your logo's path
              height: 50,
              width: 50,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),

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

            // Date Picker Field
            buildLabelField('Date:', 'Select Date', isDatePicker: true),
            SizedBox(height: 20),
            buildLabelField('Type of Transaction:', 'Select Transaction', isDropdown: true),
            SizedBox(height: 20),
            buildLabelField('Enter Amount:', 'Amount'),
            SizedBox(height: 20),
            buildLabelField('Enter Description:', 'Description'),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _addTransaction,
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
                MaterialPageRoute(
                    builder: (context) => HomePage(userId: widget.userId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => FinenseTrackerApp(userId: widget.userId)),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => FinancialSummaryApp(userId: widget.userId)),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TransactionsHistory(userId: widget.userId)),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileApp(userId: widget.userId)),
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

  // Function to trigger date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Initial date is today
      firstDate: DateTime(2000), // First date in the past the user can select
      lastDate: DateTime(2101), // Future date limit
    );

    if (selectedDate != null) {
      // Update the date field with the selected date
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format date as YYYY-MM-DD
      });
    }
  }

  // Add transaction to Firestore
  void _addTransaction() async {
    final amount = _amountController.text.trim();
    final description = _descriptionController.text.trim();
    final date = _dateController.text.trim();

    if (_transactionType == 'Select transaction type') {
      // Show error if the user didn't select a valid transaction type
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please select a transaction type.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (amount.isEmpty || description.isEmpty || date.isEmpty) {
      // Show error if fields are empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill in all fields.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      // Ensure the date is valid
      DateTime parsedDate = DateTime.parse(date); // Date parsing
      Timestamp timestamp = Timestamp.fromDate(parsedDate); // Convert to Firestore Timestamp

      // Check if the user is authenticated
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user == null) {
        // Handle case where the user is not authenticated
        print("User is not authenticated");
        return;
      }

      String userId = user.uid; // Correctly fetch the authenticated user's ID

      // Add transaction to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId) // Ensure this points to the correct user document
          .collection('transactions')
          .add({
        'date': timestamp, // Store as Timestamp
        'transaction_type': _transactionType,
        'amount': double.tryParse(amount) ?? 0.0, // Convert amount to double
        'description': description,
      });

      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction added successfully')),
      );

      // Clear input fields
      _amountController.clear();
      _descriptionController.clear();
      _dateController.clear();
      setState(() {
        _transactionType = 'Select transaction type'; // Reset to default
      });
    } catch (e) {
      // Handle error
      print('Error adding transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding transaction: $e')),
      );
    }
  }


  Widget buildLabelField(String label, String placeholder, {bool isDropdown = false, bool readOnly = false, bool isDatePicker = false}) {
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
        isDatePicker
            ? TextField(
          controller: _dateController,
          readOnly: true, // Prevent manual entry
          onTap: () => _selectDate(context), // Trigger date picker on tap
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        )
            : isDropdown
            ? DropdownButtonFormField<String>(
          value: _transactionType,
          items: [
            DropdownMenuItem(
              value: 'Select transaction type',
              child: Text('Select transaction type'),
            ),
            DropdownMenuItem(
              value: 'Income',
              child: Text('Income'),
            ),
            DropdownMenuItem(
              value: 'Expense',
              child: Text('Expense'),
            ),
          ],
          onChanged: (value) {
            if (value != 'Select transaction type') {
              setState(() {
                _transactionType = value!;
              });
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        )
            : TextField(
          controller: placeholder == 'Amount' ? _amountController : _descriptionController,
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
