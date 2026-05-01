import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/models/user_model.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../constant/AppStyle.dart';
import '../../constant/Colors.dart';
import '../../models/service_model.dart';

class BookedServiceDetails extends StatefulWidget {
  final String serviceId;

  const BookedServiceDetails({super.key, required this.serviceId});

  @override
  State<BookedServiceDetails> createState() => _BookedServiceDetailsState();
}

class _BookedServiceDetailsState extends State<BookedServiceDetails> {
  Future<ServiceAndUserData> fetchServiceAndUserByServiceId(
    String serviceId,
  ) async {
    try {
      // Step 1: Fetch the service data
      final serviceDoc =
          await FirebaseFirestore.instance
              .collection('submitted_services')
              .doc(serviceId)
              .get();

      if (!serviceDoc.exists) {
        throw Exception('Service not found');
      }

      final service = ServiceModel.fromJson2(serviceDoc.data()!, serviceDoc.id);

      // Step 2: Get user_id from index_table
      final indexQuery =
          await FirebaseFirestore.instance
              .collection('index')
              .where('serviceId', isEqualTo: serviceId)
              .limit(1)
              .get();

      if (indexQuery.docs.isEmpty) {
        throw Exception('Index entry not found for this service ID');
      }

      final indexData = indexQuery.docs.first.data();
      final userId = indexData['userUid'];

      if (userId == null) {
        throw Exception('User ID not found in index table');
      }

      // Step 3: Fetch user document
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final user = UserModel.fromJson(userDoc.data()!, userDoc.id);

      return ServiceAndUserData(service: service, user: user);
    } catch (e) {
      throw Exception('Error fetching service/user data: $e');
    }
  }

  void callUser(String phoneNumber) {
    final tel = 'tel:$phoneNumber';
    launchUrlString(tel, mode: LaunchMode.externalApplication).catchError((e) {
      Fluttertoast.showToast(msg: "Error: $e");
    });
  }

  Future<void> cancelBooking(String serviceId) async {
    try {
      LoadingDialog.show(context);

      // Query the index_table where service_id matches
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('index') // Replace with your collection name
              .where('serviceId', isEqualTo: serviceId)
              .get();

      if (querySnapshot.docs.isEmpty) {
        print('No document found with service_id: $serviceId');
        Fluttertoast.showToast(
          msg: "Something went wrong. We can't cancel the booking",
        );
        return;
      }

      for (var doc in querySnapshot.docs) {
        // Update the status field to 'pending'
        await FirebaseFirestore.instance.collection('index').doc(doc.id).update(
          {'status': 'active'},
        );

        LoadingDialog.hide(context);
        Fluttertoast.showToast(msg: "Booking is cancelled successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ServiceAndUserData>(
      future: fetchServiceAndUserByServiceId(
        widget.serviceId,
      ), // Call the fetch function
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Service not found'));
        }

        final service = snapshot.data!; // Access the fetched service model
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: BackButton(color: Colors.black),
            title: Text("Booked Service Details", style: AppStyle.fontMedium),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: AppColor.blackColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_taxi,
                              color: AppColor.blackColor,
                              size: 30,
                            ),
                            SizedBox(width: screenHeight * 0.005),
                            Text(
                              service.service.category,
                              style: AppStyle.fontMedium,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.my_location,
                              color: AppColor.primaryColor,
                            ),
                            SizedBox(width: screenHeight * 0.005),
                            Text(
                              service.service.location.toString(),
                              style: AppStyle.fontMedium12,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.network(
                                  service.service.imgURL.toString(),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: screenHeight * 0.01),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${service.user.name} ",
                                  style: AppStyle.fontMedium12,
                                ),
                                SizedBox(height: screenHeight * 0.0005),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.call,
                                      color: AppColor.primaryColor,
                                      size: 20,
                                    ),
                                    Text(
                                      "${service.user.number} ",
                                      style: AppStyle.font12,
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.01),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children:
                                      service.service.attributes.map((entry) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${entry['key']}: ",
                                                style: AppStyle.fontMedium12,
                                              ),

                                              Text(
                                                "${entry['value']}",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton(
                          onPressed: () {
                            callUser(service.user.number);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            backgroundColor: AppColor.primaryColor,
                          ),
                          child: Text(
                            "Call Now",
                            style: TextStyle(color: AppColor.whiteColor),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.01),
                        ElevatedButton(
                          onPressed: () async {
                            await cancelBooking(widget.serviceId);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            backgroundColor: AppColor.redColor,
                          ),
                          child: Text(
                            "Cancel Booking",
                            style: TextStyle(color: AppColor.whiteColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ServiceAndUserData {
  final ServiceModel service;
  final UserModel user;

  ServiceAndUserData({required this.service, required this.user});
}
