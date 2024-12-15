import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user?.uid ?? '';
      if (uid.isEmpty) {
        return "UID generation failed";
      }

      // Save user details to Firestore with default empty values
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'full_name': '', // Initially empty
        'phone_number': '', // Initially empty
      }).then((value) {
        print("User data added to Firestore");
      }).catchError((e) {
        print("Error adding user data: $e");
      });

      return uid; // Success
    } catch (e) {
      print("Error: $e");  // Add logging here
      return e.toString(); // Return the error message
    }
  }

  // Login Method
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? uid = userCredential.user?.uid; // Get the user ID
      if (uid != null) {
        // Optionally fetch user-specific data from Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          // You can now access the specific data for this user
          print('User data: ${userDoc.data()}');
        } else {
          print('User document does not exist');
        }
      }

      return uid; // Return the user ID on success
    } catch (e) {
      return e.toString(); // Return error message on failure
    }
  }

  // Google Sign-In Method
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return "Sign in aborted by user";
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        // Check if the user already exists in Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // Add a new user document with default values
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email ?? 'Not set',
            'full_name': user.displayName ?? 'Not set',
            'phone_number': 'Not set', // Default value
          });
        }
        return user.uid;
      } else {
        return "Google sign-in failed";
      }
    } catch (e) {
      print("Google sign-in error: $e");
      return e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
