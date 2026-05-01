import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/constant/Colors.dart';
import 'package:dealtheka/models/user_model.dart';
import 'package:dealtheka/widgets/custom_button.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MyBookedServices extends StatefulWidget {
  const MyBookedServices({super.key});

  @override
  State<MyBookedServices> createState() => _MyBookedServicesState();
}

class _MyBookedServicesState extends State<MyBookedServices> {
  Future<String?> getLoggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (doc.exists) {
        return doc.data();
      } else {
        Fluttertoast.showToast(msg: "User not found.");
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Something went wrong. We can't fetch user details",
      );
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String? loggedInUserId = await getLoggedInUserId();

    if (loggedInUserId == null) return [];

    final bookingsSnapshot = await firestore.collection('bookings')
        .orderBy('booking_date', descending: true)
        .get();

    List<Map<String, dynamic>> userBookings = [];

    for (var bookingDoc in bookingsSnapshot.docs) {
      var bookingData = bookingDoc.data();
      String indexId = bookingData['index_id'];

      // Fetch index document
      var indexDoc = await firestore.collection('index').doc(indexId).get();
      if (indexDoc.exists) {
        var indexData = indexDoc.data();
        final userData= await getUserDetails(bookingData['uid'].toString());
        if (indexData != null && indexData['userUid'] == loggedInUserId) {
          // Merge both booking and index data
          userBookings.add({
            ...bookingData,
            'bookingId': bookingDoc.id,
            'serviceId': indexData['serviceId'],
            'userId': indexData['userUid'],
            'BookedUserId': bookingData['uid'],
            'mobileNumber': userData?['number']?.toString()??'',
          });
        }
      }
    }

    return userBookings;
  }

  // Example: Convert Firestore timestamp to formatted date string
  String formatBookingDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
    String formattedDate = DateFormat(
      'dd-MM-yyyy',
    ).format(dateTime); // Format it
    return formattedDate;
  }

  late Future<List<Map<String, dynamic>>> bookingsFuture;

  @override
  void initState() {
    super.initState();
    bookingsFuture = getUserBookings();
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      LoadingDialog.show(context);

      final bookingsRef = FirebaseFirestore.instance.collection('bookings');
      final indexRef = FirebaseFirestore.instance.collection('index');

      DocumentSnapshot bookingDoc = await bookingsRef.doc(bookingId).get();

      if (!bookingDoc.exists) {
        Fluttertoast.showToast(msg: "Booking not found.");
        return;
      }
      await bookingsRef.doc(bookingId).update({'status': "Cancelled"});

      final indexId = bookingDoc['index_id'];

      // Step 4: Update status in the index collection
      await indexRef.doc(indexId).update({'status': "active"});

      setState(() {
        bookingsFuture = getUserBookings();
      });

      Fluttertoast.showToast(msg: "Booking cancelled successfully.");

      LoadingDialog.hide(context);
    } catch (e) {
      LoadingDialog.hide(context);
      Fluttertoast.showToast(
        msg: "Something went wrong. We can't cancel the booking",
      );
    }
  }

  void callUser(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No bookings found."));
        }

        final bookings = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                bookings.map((booking) {
                  return Container(
                    width: 200,
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColor.primaryColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<Map<String, dynamic>?>(
                          future: getUserDetails(booking['BookedUserId']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              return Text('User not found');
                            }

                            final userData = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: Ink.image(
                                    image:
                                        userData['img'] != null &&
                                                userData['img'].isNotEmpty
                                            ? NetworkImage(userData['img'])
                                            : AssetImage(
                                                  'assets/images/profile.png',
                                                )
                                                as ImageProvider,
                                    fit: BoxFit.cover,
                                    height: screenWidth * 0.12,
                                    width: screenWidth * 0.12,
                                  ),
                                ),

                                Text(
                                  "${userData['username']}",
                                  style: AppStyle.fontMedium12,
                                ),
                                SizedBox(height: screenWidth * 0.009),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.call,
                                      color: AppColor.primaryColor,
                                      size: screenWidth * 0.05,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text(
                                      "${userData['number']}",
                                      style: AppStyle.fontMedium12,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: screenWidth * 0.009),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Date: ", style: AppStyle.fontMedium12),
                            Text(
                              formatBookingDate(booking['booking_date']),
                              style: AppStyle.font12,
                            ),
                          ],
                        ),

                        SizedBox(height: screenWidth * 0.009),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Status: ", style: AppStyle.fontMedium12),
                            Text(
                              "${(booking['status'])}",
                              style: AppStyle.font12,
                            ),
                          ],
                        ),

                        (booking['status'] == 'Pending')
                            ? Column(
                              children: [
                                SizedBox(height: screenWidth * 0.04),

                                CustomButton(
                                  text: "Call Now",
                                  onPressed: () =>callUser(booking['mobileNumber']),
                                ),

                                SizedBox(height: screenWidth * 0.02),
                                TextButton(
                                  onPressed:
                                      () => cancelBooking(booking['bookingId']),
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppColor.redColor,
                                    foregroundColor: AppColor.whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel Booking",
                                    style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Column(
                              children: [
                                SizedBox(height: screenWidth*0.04),
                                TextButton(
                                  onPressed:
                                      () => {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: (booking['status']=="Cancelled"?AppColor.redColor:AppColor.greenColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel Booking",
                                    style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}
