import 'package:dealtheka/constant/AppStyle.dart';
import 'package:flutter/material.dart';


class IconTextIconInRow extends StatelessWidget {
  final IconData iconData;
  final String text;
  final VoidCallback onTap;

  const IconTextIconInRow({super.key, required this.iconData, required this.text,  required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenHeight= MediaQuery.of(context).size.height;
    final screenWidth= MediaQuery.of(context).size.width;



    return GestureDetector(
      onTap: onTap,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         Row(
           children: [
             Icon(iconData, size: screenHeight*0.035),
             SizedBox(width: screenWidth*0.04,),
             Text(text, style: AppStyle.fontMedium12),
           ],
         ),
          Icon(Icons.arrow_forward_ios_outlined, size: screenHeight*0.018,)
        ],
      ),
    );
  }
}
