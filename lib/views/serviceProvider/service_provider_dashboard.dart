import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/controllers/dashboard_controller.dart';
import 'package:dealtheka/views/serviceProvider/my_booked_services.dart';
import 'package:dealtheka/widgets/common/button/TextButton.dart';
import 'package:dealtheka/widgets/footer.dart';
import 'package:dealtheka/widgets/header.dart';
import 'package:dealtheka/widgets/serviceProviderPack/my_services.dart';
import 'package:dealtheka/widgets/userPacks/slider.dart';
import 'package:flutter/material.dart';

class ServiceProviderDashboard extends StatefulWidget {
  const ServiceProviderDashboard({super.key});

  @override
  State<ServiceProviderDashboard> createState() => _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {

  final ServiceController _controller= ServiceController();

  int cancelled = 0;
  int pending = 0;
  int total = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   final total=  _controller.getTotalCancelledBookingsForLoggedInUser();

    _loadBookingStats();
  }

  void _loadBookingStats() async {
    final totalData = await _controller.getTotalCancelledBookingsForLoggedInUser();

    setState(() {
      cancelled = totalData['cancel'] ?? 0;
      pending = totalData['pending'] ?? 0;
      total = totalData['total'] ?? 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;



    return Scaffold(
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
                            AppHeader(),

                            SizedBox(height: screenHeight * 0.02),

                            Text(
                              "Dashboard",
                              style: AppStyle.fontMedium,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                               Column(
                                 children: [
                                   Text("Active Jobs", style: AppStyle.fontMedium,),
                                   Text("$pending"),
                                 ],
                               ),

                                Column(
                                  children: [
                                    Text("Cancel Jobs", style: AppStyle.fontMedium,),
                                    Text("$cancelled"),
                                  ],
                                ),

                                Column(
                                  children: [
                                    Text("Total Jobs", style: AppStyle.fontMedium,),
                                    Text("$total"),
                                  ],
                                ),

                              ],
                            ),

                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              "Recent Booking",
                              style: AppStyle.fontMedium,
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            MyBookedServices(),

                            SizedBox(height: screenHeight * 0.02),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "My Services",
                                  style: AppStyle.fontMedium,
                                ),
                                
                                CustomTextButton(buttonText: "Add Service", routeName: "/select-category")
                              ],
                            ),

                            MyServices(),
                            SizedBox(height: screenHeight * 0.02),

                            Text(
                              "What Our Customer Say",
                              style: AppStyle.fontMedium,
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            TestimonialSlider(),


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
