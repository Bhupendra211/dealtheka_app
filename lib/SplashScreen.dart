import 'package:dealtheka/constant/Colors.dart';
import 'package:dealtheka/views/auth/register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  Future<void> _initSplash() async {
    final prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid') ?? '';
    await _checkUser(uid);
  }

  // Check if the user is logged in and navigate accordingly
  Future<void> _checkUser(String uid) async {
    if (uid.isNotEmpty) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          String role = userDoc['role'] ?? 'user';
          if (role == 'admin') {
            Navigator.pushNamedAndRemoveUntil(context, '/admin-dashboard', (route) => false);
          } else if(role=="user") {
            Navigator.pushNamedAndRemoveUntil(context, '/user-dashboard', (route) => false);
          }else{
            Navigator.pushNamedAndRemoveUntil(context, '/service-provider-dashboard',(route) => false);
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/register', (route) => false);
        }
      } catch (e) {
        // Handle any errors here, e.g. network issues
        Navigator.pushNamedAndRemoveUntil(
            context, '/register', (route) => false);
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, '/register', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double logoSize = constraints.maxWidth * 0.5;
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColor.primaryColor,
              child: Image.asset(
                'assets/images/logo.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ),
    );
  }
}
