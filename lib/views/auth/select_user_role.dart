import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _InterestSelectionPageState();
}

class _InterestSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedInterest;

  // Mapping between UI text and DB values
  final Map<String, String> roleMap = {
    'Customer': 'user',
    'Services Provider': 'service provider',
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final screenWidth= size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative Circles
            Positioned(
              top: -size.width * 0.65,
              left: -size.width * 0.65,
              child: CircleAvatar(
                radius: size.width * 0.5,
                backgroundColor: Colors.blue[800],
              ),
            ),
            Positioned(
              top: -size.width * 0.65,
              right: -size.width * 0.65,
              child: CircleAvatar(
                radius: size.width * 0.5,
                backgroundColor: Colors.blue[800],
              ),
            ),
            Positioned(
              bottom: -size.width * 0.65,
              left: -size.width * 0.65,
              child: CircleAvatar(
                radius: size.width * 0.5,
                backgroundColor: Colors.blue[800],
              ),
            ),
            Positioned(
              bottom: -size.width * 0.65,
              right: -size.width * 0.65,
              child: CircleAvatar(
                radius: size.width * 0.5,
                backgroundColor: Colors.blue[800],
              ),
            ),
            Column(
              children: [
                SizedBox(height: height * 0.1),
                Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: height * 0.2),

                        // Dropdown
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth*0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("You are interested in "),
                              const SizedBox(width: 10),
                              DropdownButton<String>(
                                value: _selectedInterest,
                                hint: const Text("Choose"),
                                items: roleMap.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.value, // value saved in Firestore
                                    child: Text(entry.key), // displayed label
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedInterest = newValue;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.05),

                        // Button
                        ElevatedButton(
                          onPressed: _selectedInterest == null
                              ? null
                              : () async {
                            try {
                              LoadingDialog.show(context);
                              final prefs = await SharedPreferences.getInstance();
                              final uid = prefs.getString('uid');

                              if (uid != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .update({
                                  'role': _selectedInterest,
                                });

                                await prefs.setString('role', _selectedInterest!);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Role updated to $_selectedInterest'),
                                  ),
                                );

                                LoadingDialog.hide(context);
                                // Navigate based on role
                                if (_selectedInterest == "user") {
                                  Navigator.pushReplacementNamed(context, "/user-dashboard");
                                } else {
                                  Navigator.pushReplacementNamed(context, "/upload-documents");
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('User ID not found')),
                                );
                              }
                            } catch (e) {
                              LoadingDialog.hide(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Failed to update role: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Next",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
