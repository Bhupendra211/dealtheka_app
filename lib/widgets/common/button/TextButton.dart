import 'package:flutter/material.dart';
import 'package:dealtheka/constant/Colors.dart'; // Make sure you import your colors

class CustomTextButton extends StatelessWidget {
  final String buttonText;
  final String routeName;
  final VoidCallback? onPressed;

  const CustomTextButton({
    super.key,
    required this.buttonText,
    required this.routeName,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: AppColor.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: onPressed ??
              () {
            Navigator.pushNamed(context, routeName);
          },
      child: Text(buttonText),
    );
  }
}
