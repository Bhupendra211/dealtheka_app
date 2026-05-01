import 'package:dealtheka/constant/Colors.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import '../../controllers/register_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController controller = RegisterController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height; // For responsiveness
    double width = MediaQuery.of(context).size.width;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Circles
          Positioned(
            top: -size.width * 0.65,
            left: -size.width * 0.65,
            child: CircleAvatar(
              radius: size.width * 0.5,
              backgroundColor: AppColor.primaryColor,
            ),
          ),
          Positioned(
            top: -size.width * 0.65,
            right: -size.width * 0.65,
            child: CircleAvatar(
              radius: size.width * 0.5,
              backgroundColor: AppColor.primaryColor,
            ),
          ),
          Positioned(
            bottom: -size.width * 0.65,
            left: -size.width * 0.65,
            child: CircleAvatar(
              radius: size.width * 0.5,
              backgroundColor: AppColor.primaryColor,
            ),
          ),
          Positioned(
            bottom: -size.width * 0.65,
            right: -size.width * 0.65,
            child: CircleAvatar(
              radius: size.width * 0.5,
              backgroundColor: AppColor.primaryColor,
            ),
          ),

          // Scrollable and Full-Height Content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: width * 0.08,
                  right: width * 0.08,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: height * 0.08),
                        Image.asset(
                          'assets/images/logo.png',
                          height: height * 0.2,
                        ),
                        Center(
                          child: Text(
                            'Start your journey',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Center(
                          child: Text(
                            "Let's start with us",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        CustomTextField(
                          controller: controller.usernameController,
                          hintText: 'Enter your username',
                          prefixIcon: Icons.person,
                        ),
                        SizedBox(height: height * 0.02),
                        CustomTextField(
                          controller: controller.emailController,
                          hintText: 'Enter your email address',
                          prefixIcon: Icons.email,
                        ),
                        SizedBox(height: height * 0.02),
                        CustomTextField(
                          controller: controller.mobileController,
                          hintText: 'Enter your mobile number',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: height * 0.02),
                        CustomTextField(
                          controller: controller.passwordController,
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock,
                          obscureText: controller.obscurePassword,
                          onSuffixTap: () {
                            setState(() {
                              controller.togglePasswordVisibility(
                                    () => setState(() {}),
                              );
                            });
                          },
                        ),
                        SizedBox(height: height * 0.04),
                        CustomButton(
                          text: "Register",
                          onPressed: () async {
                            await controller.register(context);
                          },
                        ),
                        SizedBox(height: height * 0.025),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("I already have an account. "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: Text(
                                "Login here",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        Spacer(), // pushes everything above and fills full screen
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

  }
}
