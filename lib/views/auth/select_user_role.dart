import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool isLoading = false;

  Future<void> selectRole(String role) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      LoadingDialog.show(context);

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');

      if (uid == null) {
        throw Exception('User ID not found');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'role': role});

      await prefs.setString('role', role);

      if (!mounted) return;

      LoadingDialog.hide(context);
      setState(() => isLoading = false);

      if (role == 'user') {
        Navigator.pushReplacementNamed(context, '/user-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/select-category');
      }
    } catch (e) {
      if (!mounted) return;

      LoadingDialog.hide(context);
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update role: $e')),
      );
    }
  }

  Widget roleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Icon(icon, size: 45, color: Colors.blue[800]),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.blue[800]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 25),
                const Text(
                  'Welcome to Deal Theka',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Choose how you want to continue'),
                const SizedBox(height: 35),

                roleCard(
                  icon: Icons.person,
                  title: 'Customer',
                  subtitle: 'Explore services and find providers',
                  onTap: () => selectRole('user'),
                ),

                const SizedBox(height: 20),

                roleCard(
                  icon: Icons.business_center,
                  title: 'Service Provider',
                  subtitle: 'Choose a service and add your work',
                  onTap: () => selectRole('service provider'),
                ),

                if (isLoading) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
