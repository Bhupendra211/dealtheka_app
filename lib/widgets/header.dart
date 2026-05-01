import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/constant/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String name = ''; // To store user name
  String role = ''; // To store user role
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    getProfile();
  }

  // Load name and role from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name =
          prefs.getString('username') ??
          'Guest'; // Default to 'Guest' if not found
      role =
          prefs.getString('role') ?? 'user'; // Default to 'user' if not found
    });
  }

  Future<void> getProfile() async {
    try {
      String uid = await getUidFromPrefs();

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('profile')) {
          setState(() {
            profileImageUrl = data['profile'];
          });
        }
      } else {
        print("User not found in Firestore");
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<String> getUidFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid') ?? ''; // Default to 'user' if not found
    return uid;
  }

  // Logout function to clear SharedPreferences and navigate to login screen
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all data from SharedPreferences
    Navigator.pushReplacementNamed(
      context,
      "/login",
    ); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Profile Image (Circular)
              ClipOval(
                child:
                    profileImageUrl != null
                        ? Image.network(
                          profileImageUrl!,
                          fit: BoxFit.cover,
                          height: screenWidth * 0.12,
                          width: screenWidth * 0.12,
                        )
                        : Image.asset(
                          'assets/images/profile.png',
                          fit: BoxFit.cover,
                          height: screenWidth * 0.12,
                          width: screenWidth * 0.12,
                        ),
              ),
              // Column for Name and Role
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppStyle.fontMedium12),
                    Text(role), // Update role dynamically
                  ],
                ),
              ),
              // Dropdown Menu for Role-based Options
              PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'profile') {
                    Navigator.pushNamed(context, '/profile');
                  } else if (value == 'settings') {
                    Navigator.pushNamed(context, '/settings');
                  } else if (value == 'my service') {
                    Navigator.pushNamed(context, '/my-service');
                  } else if (value == 'logout') {
                    _logout(); // Handle logout
                  }
                },
                itemBuilder: (BuildContext context) {
                  // Show different options based on role
                  if (role == 'admin') {
                    return [
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.account_circle_rounded),
                            SizedBox(width: screenWidth * 0.02),
                            Text('Profile'),
                          ],
                        ),
                      ),
                      // PopupMenuItem<String>(
                      //   value: 'settings',
                      //   child: Row(
                      //     children: [
                      //       Icon(Icons.settings),
                      //       SizedBox(width: screenWidth * 0.02),
                      //       Text('Settings')
                      //     ],
                      //   ),
                      // ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: screenWidth * 0.02),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ];
                  } else if (role == 'user') {
                    return [
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Text('Profile'),
                      ),

                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ];
                  } else {
                    return [
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Text('Profile'),
                      ),
                      PopupMenuItem<String>(
                        value: 'my service',
                        child: Text('My Services'),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ];
                  }
                },
                icon: Icon(Icons.arrow_drop_down), // Icon for the dropdown
              ),
            ],
          ),
          // Notification Icon
          Icon(Icons.notifications_on_outlined),
        ],
      ),
    );
  }
}
