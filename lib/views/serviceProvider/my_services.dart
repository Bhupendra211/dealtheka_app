import 'package:flutter/material.dart';

import '../../constant/AppStyle.dart';
import '../../widgets/common/button/TextButton.dart';
import '../../widgets/footer.dart';
import '../../widgets/serviceProviderPack/my_services.dart';

class MyServicesPage extends StatefulWidget {
  const MyServicesPage({super.key});

  @override
  State<MyServicesPage> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServicesPage> {
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
        title: Text("My Services", style: AppStyle.fontMedium),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "My Services",
                                  style: AppStyle.fontMedium,
                                ),

                                CustomTextButton(buttonText: "Add Service", routeName: "/select-category")
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            MyServices(),
                            SizedBox(height: screenHeight * 0.02),


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
