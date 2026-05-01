import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Text("Made in India"),
          Text("Developer & Design by Bhupendra")
        ],
      ),
    );
  }
}
