import 'package:flutter/material.dart';
import 'register.dart';

void main() => runApp(FinenseApp());

class FinenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add logo here
          Image.asset(
            'finsense-logo.png', 
            height: 100, 
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centers the texts horizontally
            children: [
              Text(
                'Welcome to ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 8, 50, 112),
                ),
              ),
              Text(
                'FINENSE!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 6, 37, 88),
                ),
              ),
            ],
          ),

          SizedBox(height: 30),
          TextField(
            decoration: InputDecoration(
              hintText: 'Username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // deri ibutang pag ang button e press
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'LOGIN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'or',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 8, 50, 112),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  // function sa google api
                },
                child: Image.asset(
                  'assets/Google.png', // Replace with your image path
                  height: 30,
                  width: 30,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate sa Signup screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateAccountApp()),
                  );
                },
                child: Text(
                  "Sign up",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 7, 40, 88),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      )),
    ));
  }
}
