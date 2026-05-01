import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/constant/Colors.dart';
import 'package:flutter/material.dart';

class ServiceBox extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  const ServiceBox({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth*0.05, vertical: screenHeight*0.01),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColor.blackColor,
            width: 1,
          ),
          color: AppColor.lightWhiteColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important: keeps size compact
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: screenWidth*0.05, color: AppColor.primaryColor),
            Flexible(
              child: Text(
                text,
                style: AppStyle.fontMedium12,
                textAlign: TextAlign.left,
                maxLines: 1,                 // 🔥 limit lines
                overflow: TextOverflow.ellipsis,  // 🔥 add ...
              ),
            ),
          ],
        ),
      ),
    );
  }
}
