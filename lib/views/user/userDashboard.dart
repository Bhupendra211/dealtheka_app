import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/widgets/footer.dart';
import 'package:dealtheka/widgets/header.dart';
import 'package:dealtheka/widgets/showServices.dart';
import 'package:dealtheka/widgets/userPacks/recent_booking.dart';
import 'package:dealtheka/widgets/userPacks/slider.dart';
import 'package:flutter/material.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight( // ✅ Important Fix
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

                            /// 🔍 SEARCH
                            Text("Search", style: AppStyle.fontMedium),
                            SizedBox(height: screenHeight * 0.01),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(width: 1),
                              ),
                              child: TextField(
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    Navigator.pushNamed(
                                      context,
                                      '/search-detail',
                                      arguments: value,
                                    );
                                  }
                                },
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  hintText: "Search for our services....",
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            /// 📅 RECENT BOOKINGS
                            Text("Recent Bookings", style: AppStyle.fontMedium),
                            SizedBox(height: 8),
                            RecentBooking(),

                            SizedBox(height: screenHeight * 0.02),

                            /// 🛠 OUR SERVICES
                            Text("Our Services", style: AppStyle.fontMedium),
                            SizedBox(height: 8),

                            // ✅ FIXED: Removed Row wrapper
                            ShowServices(),

                            SizedBox(height: screenHeight * 0.02),

                            /// 💬 TESTIMONIAL
                            Text(
                              "What Our Customer Say",
                              style: AppStyle.fontMedium,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            TestimonialSlider(),
                          ],
                        ),
                      ),

                      const Spacer(), // Push footer down

                      /// 👣 FOOTER
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