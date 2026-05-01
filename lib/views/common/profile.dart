import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/widgets/icon_text_icon_in_row.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/AppStyle.dart';
import '../../widgets/footer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String role = '';
  String? profileImageUrl;

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all data from SharedPreferences
    Navigator.pushReplacementNamed(
      context,
      "/login",
    ); // Navigate to login screen
  }

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
      role = prefs.getString('role') ?? ''; // Default to 'user' if not found
    });
  }

  Future<void> getProfile() async {
    try {
      String uid = await getUidFromPrefs();

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('profileImage')) {
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

  Future<String?> uploadProfileImageToCloudinary() async {
    LoadingDialog.show(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final uid = await getUidFromPrefs();

    final file = File(pickedFile.path);
    final cloudinaryUploadUrl = Uri.parse(
      'https://api.cloudinary.com/v1_1/dlnxmbal5/image/upload',
    );
    final uploadPreset = 'dealtheka';

    final request =
        http.MultipartRequest('POST', cloudinaryUploadUrl)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      final imageUrl = responseData['secure_url'];

      // Save image URL to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profile': imageUrl,
      });
      LoadingDialog.hide(context);
Fluttertoast.showToast(msg: "Profile image uploaded successfully");
      return imageUrl;
    } else {
      LoadingDialog.hide(context);
      Fluttertoast.showToast(msg: "Something went wrong. We can't upload profile image");

      print('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text("Create New Service", style: AppStyle.fontMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.05),

                            Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  ClipOval(
                                    child:
                                        profileImageUrl != null
                                            ? Image.network(
                                              profileImageUrl!,
                                              fit: BoxFit.cover,
                                              height: screenWidth * 0.2,
                                              width: screenWidth * 0.2,
                                            )
                                            : Image.asset(
                                              'assets/images/profile.png',
                                              fit: BoxFit.cover,
                                              height: screenWidth * 0.2,
                                              width: screenWidth * 0.2,
                                            ),
                                  ),

                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 14,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(Icons.edit, size: 18),
                                        onPressed: () async{
                                          final newUrl = await uploadProfileImageToCloudinary();
                                          if (newUrl != null) {
                                            setState(() {
                                              profileImageUrl = newUrl;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.1),

                            IconTextIconInRow(
                              iconData: Icons.account_circle_rounded,
                              text: "Profile Details",
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  "/profile-details",
                                );
                              },
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            IconTextIconInRow(
                              iconData: Icons.account_circle_rounded,
                              text: "History",
                              onTap: () {
                                Navigator.pushNamed(context, "/history");
                              },
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            (role == "service provider"
                                ? Column(
                              children: [
                                IconTextIconInRow(
                                  iconData: Icons.design_services_outlined,
                                  text: "My Services",
                                  onTap: () {
                                    Navigator.pushNamed(context, '/my-service');
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.02),

                              ],
                            )
                                : SizedBox(height: 0,)),

                            IconTextIconInRow(
                              iconData: Icons.support_agent_outlined,
                              text: "Help & Support",
                              onTap: () {
                                Navigator.pushNamed(context, '/faq');
                              },
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            IconTextIconInRow(
                              iconData: Icons.chat_outlined,
                              text: "FAQ's",
                              onTap: () {
                                Navigator.pushNamed(context, '/faq');
                              },
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            IconTextIconInRow(
                              iconData: Icons.logout_rounded,
                              text: "Logout",
                              onTap: () async {
                                Fluttertoast.showToast(
                                  msg: "Logout Successfully",
                                );
                                _logout();
                              },
                            ),

                            SizedBox(height: screenHeight * 0.2),
                            Center(
                              child: Text(
                                "App Version: 1.0.0",
                                style: AppStyle.fontMedium12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(), // Pushes footer to bottom when content is short
                      AppFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
