import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/widgets/history_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/AppStyle.dart';
import '../../widgets/footer.dart';

class History_Screen extends StatefulWidget {
  const History_Screen({super.key});

  @override
  State<History_Screen> createState() => _History_ScreenState();
}

class _History_ScreenState extends State<History_Screen> {
  Future<String?> getUidFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }


  Future<List<Map<String, dynamic>>> fetchMergedBookingData(String uid) async {
    final firestore = FirebaseFirestore.instance;

    // Step 1: Get bookings by UID
    final bookingSnapshot = await firestore
        .collection('bookings')
        .where('uid', isEqualTo: uid)
        .get();

    List<Map<String, dynamic>> mergedData = [];

    for (var bookingDoc in bookingSnapshot.docs) {
      final bookingData = bookingDoc.data();
      final indexId = bookingData['index_id'];

      // Step 2: Get service_id from index table
      final indexDoc = await firestore.collection('index').doc(indexId).get();
      final serviceId = indexDoc.data()?['serviceId'];

      if (serviceId != null) {
        // Step 3: Get service details from submitted_services
        final serviceDoc = await firestore.collection('submitted_services').doc(serviceId).get();
        final serviceData = serviceDoc.data();

        final bookingDate = bookingData['booking_date'];
        String formattedDate = "Invalid date";

        if (bookingDate is Timestamp) {
          formattedDate = DateFormat('dd-MM-yyyy').format(bookingDate.toDate());
        }

        // Step 4: Merge serviceData into bookingData
        if (serviceData != null) {
          mergedData.add({
            ...bookingData,
            'serviceName': serviceData['category'] ?? 'Unknown',
            'location':serviceData['location']??"Unknown",
            'formattedDate': formattedDate,
          });
        } else {
          mergedData.add(bookingData); // fallback if no service data
        }
      } else {
        mergedData.add(bookingData); // fallback if no serviceId found
      }
    print("mergedData: $mergedData");
    }


    return mergedData;
  }



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
        title: Text("History", style: AppStyle.fontMedium),
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
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                        ),
                        child: FutureBuilder<String?>(
                          future: getUidFromPrefs(),
                          builder: (context, uidSnapshot) {
                            if (!uidSnapshot.hasData) {
                              return CircularProgressIndicator();
                            }

                            return FutureBuilder<List<Map<String, dynamic>>>(
                              future: fetchMergedBookingData(uidSnapshot.data!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Text("No bookings found."),
                                  );
                                }

                                final bookings = snapshot.data!;

                                return Column(
                                  children: [
                                    SizedBox(height: screenHeight * 0.01),
                                    for (var booking in bookings) ...[
                                      HistoryBox(
                                        icondata: Icons.taxi_alert,
                                        serviceName:
                                            booking['serviceName'] ??
                                            'Unknown Service',
                                        location: booking['location'] ??
                                            'Unknown location',
                                        date: booking['formattedDate'] ?? 'Unknown Date',
                                        status: booking['status'] ?? 'Unknown',
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                    ],
                                    SizedBox(height: screenHeight * 0.05),
                                  ],
                                );
                              },
                            );
                          },
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
