import 'package:dealtheka/constant/Colors.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import '../../controllers/register_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      resizeToAvoidBottomInset: true, // still needed
      body: Stack(
        children: [
          // Decorative Circles (Background)
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

          // Form Content (Full height and scrollable)
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
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Center(
                          child: Text(
                            "Welcome Back",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: height * 0.04),
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
                              controller.togglePasswordVisibility(() => setState(() {}));
                            });
                          },
                        ),
                        SizedBox(height: height * 0.04),
                        CustomButton(
                          text: "Login",
                          onPressed: () async {
                            await controller.loginForm(context);
                          },
                        ),
                        SizedBox(height: height * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("I don't have an account. "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, '/register');
                              },
                              child: Text(
                                "Register here",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        Spacer(), // Pushes content up to use full height
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
