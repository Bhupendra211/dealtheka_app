import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  void togglePasswordVisibility(Function updateState) {
    obscurePassword = !obscurePassword;
    updateState();
  }

  // Function to show a loading dialog
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Function to hide the loading dialog
  void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  // Register function with form validation and error handling
  Future<void> register(BuildContext context) async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();


    // Check for empty fields
    if (username.isEmpty || email.isEmpty || mobile.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Validate email format
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // Validate mobile number (only digits, 10 characters)
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    // Show loading dialog
    showLoadingDialog(context);

    try {
      // Create user with email & password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Save additional user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': username,
          'email': email,
          'number':mobile,
          'role': 'user',  // Add role to define user access type
          'createdAt': DateTime.now(),
        });

        // Save user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', userCredential.user!.uid);
        await prefs.setString('username', username);
        await prefs.setString('email', email);
        await prefs.setString('mobile', mobile);
        await prefs.setString('role', 'user');
        hideLoadingDialog(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        clearControllers();

        Navigator.pushReplacementNamed(context, "/select-role");

        print("User data saved successfully to Firestore!");
      } else {
        hideLoadingDialog(context);
        print("Error: User creation failed, user is null");
      }

      // Hide loading dialog


    } on FirebaseAuthException catch (e) {
      // Hide loading dialog
      hideLoadingDialog(context);

      String message = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        message = 'Email is already registered';
      } else if (e.code == 'weak-password') {
        message = 'Password should be at least 6 characters';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {

      print("ERROR IS: $e");
      // Hide loading dialog
      hideLoadingDialog(context);

      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong')),
      );
    }
  }


  Future<void> loginForm(BuildContext context) async {
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();

    if (mobile.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter mobile and password')),
      );
      return;
    }

    showLoadingDialog(context);

    try {
      // Search user by mobile in Firestore

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('number', isEqualTo: mobile)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        hideLoadingDialog(context);
        Fluttertoast.showToast(msg: 'Mobile number not registered');
        return;
      }

      final userData = query.docs.first.data();
      final email = userData['email'];

      // Sign in using found email and entered password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', userCredential.user!.uid);
      await prefs.setString('username', userData['username']);
      await prefs.setString('email', userData['email']);
      await prefs.setString('mobile', userData['number']);
      await prefs.setString('role', userData['role']);

      hideLoadingDialog(context);

      Fluttertoast.showToast(msg: 'Login successful');

      Navigator.pushReplacementNamed(context, "/");
    } on FirebaseAuthException catch (e) {
      hideLoadingDialog(context);

      String message = 'Login failed: ${e.message}';

      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this mobile number.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Invalid email format. Contact support.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled. Contact support.';
          break;
        case 'too-many-requests':
          message = 'Too many login attempts. Try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }

      Fluttertoast.showToast(msg: message);

      print('FirebaseAuthException: code=${e.code}, message=${e.message}');
    } catch (e) {
      hideLoadingDialog(context);
      print("Login ERROR: $e");

      Fluttertoast.showToast(msg: 'Something went wrong: $e');
    }
  }



  // Clear text controllers after registration
  void clearControllers() {
    usernameController.clear();
    emailController.clear();
    mobileController.clear();
    passwordController.clear();
  }

  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
  }
}
