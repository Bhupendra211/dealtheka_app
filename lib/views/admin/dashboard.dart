import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/widgets/common/button/TextButton.dart';
import 'package:dealtheka/widgets/footer.dart';
import 'package:dealtheka/widgets/header.dart';
import 'package:dealtheka/widgets/showServices.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {


  Future<Map<String, int>> fetchDashboardStats() async {
    final firestore = FirebaseFirestore.instance;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    // Bookings
    final allBookingsSnapshot = await firestore.collection('bookings').get();
    final todayBookingsSnapshot = await firestore
        .collection('bookings')
        .where('booking_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .get();

    // Users
    final allUsersSnapshot = await firestore.collection('users').get();

    final todayUsersSnapshot = await firestore
        .collection('users')
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .get();

    // Separate providers and regular users
    final totalUsers = allUsersSnapshot.docs.where((doc) => doc['role'] == 'user').length;
    final totalProviders = allUsersSnapshot.docs.where((doc) => doc['role'] == 'service provider').length;

    final todayUsers = todayUsersSnapshot.docs.where((doc) => doc['role'] == 'user').length;
    final todayProviders = todayUsersSnapshot.docs.where((doc) => doc['role'] == 'service provider').length;

    return {
      'totalBookings': allBookingsSnapshot.size,
      'todayBookings': todayBookingsSnapshot.size,
      'totalUsers': totalUsers,
      'todayUsers': todayUsers,
      'totalProviders': totalProviders,
      'todayProviders': todayProviders,
    };
  }

  Map<String, int> stats = {};

  @override
  void initState() {
    super.initState();
    fetchDashboardStats().then((value) {
      setState(() {
        stats = value;
      });
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
                      AppHeader(),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.02),

                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Today's Bookings", style: AppStyle.fontMedium),
                                        Text("${stats['todayBookings'] ?? 0}"),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("Total Bookings", style: AppStyle.fontMedium),
                                        Text("${stats['totalBookings'] ?? 0}"),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.01),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("New User", style: AppStyle.fontMedium),
                                        Text("${stats['todayUsers'] ?? 0}"),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("Total Users", style: AppStyle.fontMedium),
                                        Text("${stats['totalUsers'] ?? 0}"),

                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.01),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("New S.Providers", style: AppStyle.fontMedium),
                                        Text("${stats['todayProviders'] ?? 0}"),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("Total S.Provider", style: AppStyle.fontMedium),
                                        Text("${stats['totalProviders'] ?? 0}"),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.01),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Today's Earning", style: AppStyle.fontMedium),
                                        Text("0.0"),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("Total Earning", style: AppStyle.fontMedium),
                                        Text("0.0"),
                                      ],
                                    ), // or remove this if not needed
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight*0.02),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Our Services",
                                  style: AppStyle.fontMedium,
                                ),
                                CustomTextButton(
                                  buttonText: "Add Service",
                                  routeName: '/add-services',
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(children: [ShowServices()]),

                            SizedBox(height: screenHeight * 0.02),

                            Text("Details", style: AppStyle.fontMedium),

                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: [
                                CustomTextButton(
                                  buttonText: "Users",
                                  routeName: '/users-table',
                                ),

                                CustomTextButton(
                                  buttonText: "Services Providers",
                                  routeName: '/serviceProviders-table',
                                ),

                                CustomTextButton(
                                  buttonText: "Services",
                                  routeName: '/services-table',
                                ),

                                CustomTextButton(
                                  buttonText: "Bookings",
                                  routeName: '/services-table',
                                ),
                              ],
                            ),
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
