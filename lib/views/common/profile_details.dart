import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/widgets/custom_button.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/AppStyle.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/footer.dart';


class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();

  Future<String?> getUidFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }


  Future<void> loadUserData() async {
    final uid = await getUidFromPrefs();
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      usernameController.text = data?['username'] ?? '';
      emailController.text = data?['email'] ?? '';
      mobileController.text = data?['number'] ?? '';
    }
  }


  Future<void> updateUserProfile() async {
   try{
     LoadingDialog.show(context);

     final uid = await getUidFromPrefs();
     if (uid == null) return;

     await FirebaseFirestore.instance.collection('users').doc(uid).update({
       'username': usernameController.text.trim(),
       'email': emailController.text.trim(),
       'mobile': mobileController.text.trim(),
     });

     final prefs = await SharedPreferences.getInstance();
     await prefs.setString('username', usernameController.text.trim());
     await prefs.setString('email', emailController.text.trim());
     await prefs.setString('mobile', mobileController.text.trim());

     LoadingDialog.hide(context);
     Fluttertoast.showToast(msg: "Profile updated successfully");

   }catch(e){
     Fluttertoast.showToast(msg: "Something went wrong.We can't update details");
     LoadingDialog.hide(context);
     print(e);
   }
  }



  @override
  void initState() {
    super.initState();
    loadUserData();
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
                                    child: Ink.image(
                                      image: AssetImage(
                                        'assets/images/profile.png',
                                      ),
                                      fit: BoxFit.cover,
                                      height: screenWidth * 0.2,
                                      width: screenWidth * 0.2,
                                    ),
                                  ),

                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.1),

                            CustomTextField(
                              controller: usernameController,
                              hintText: 'Enter your username',
                              prefixIcon: Icons.person,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            CustomTextField(
                              controller: emailController,
                              hintText: 'Enter your email address',
                              prefixIcon: Icons.email,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            CustomTextField(
                              controller: mobileController,
                              hintText: 'Enter your mobile number',
                              prefixIcon: Icons.phone,
                              keyboardType: TextInputType.phone,
                            ),

                            SizedBox(height: screenHeight * 0.04),

                            CustomButton(text: "Update Profile", onPressed: ()=>updateUserProfile())

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
