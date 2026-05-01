import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/views/user/booked_service_details.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/AppStyle.dart';
import '../../constant/Colors.dart';
import '../../models/service_model.dart';

class BookService extends StatefulWidget {
  final String serviceId;

  const BookService({super.key, required this.serviceId});

  @override
  State<BookService> createState() => _BookServiceState();
}

class _BookServiceState extends State<BookService> {

  Future<ServiceModel> fetchServiceById(String serviceId) async {
    try {
      final serviceDoc = await FirebaseFirestore.instance
          .collection('submitted_services')
          .doc(serviceId)
          .get();


      if (serviceDoc.exists) {
        return ServiceModel.fromJson2(serviceDoc.data()!, serviceDoc.id);
      } else {
        throw Exception('Service not found');
      }
    } catch (e) {
      throw Exception('Error fetching service: $e');
    }
  }

  Future<void> bookService(String serviceId) async {
    try {
      LoadingDialog.show(context);
      // Step 1: Get UID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null) throw Exception("User not logged in");

      // Step 2: Get index document where service_id matches
      final indexQuery = await FirebaseFirestore.instance
          .collection('index')
          .where('serviceId', isEqualTo: serviceId)
          .limit(1)
          .get();

      if (indexQuery.docs.isEmpty) throw Exception("Index not found for service");

      final indexDoc = indexQuery.docs.first;
      final indexId = indexDoc.id;

      // Step 3: Update index status to 'booked'
      await FirebaseFirestore.instance
          .collection('index')
          .doc(indexId)
          .update({'status': 'booked'});

      // Step 4: Add a new booking record
      await FirebaseFirestore.instance.collection('bookings').add({
        'booking_date': Timestamp.now(),
        'status': 'Pending',
        'index_id': indexId,
        'uid': uid,
      });

      LoadingDialog.hide(context);
      Fluttertoast.showToast(msg: "Service booked successfully");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
              BookedServiceDetails(serviceId: serviceId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ServiceModel>(
      future: fetchServiceById(widget.serviceId), // Call the fetch function
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
            title: Text("Service Details", style: AppStyle.fontMedium),
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
                            Text(service.category, style: AppStyle.fontMedium),
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
                            Text(service.location.toString(), style: AppStyle.fontMedium12),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              service.imgURL.toString(),
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
                        SizedBox(height: screenHeight * 0.02),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:
                          service.attributes.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${entry['key']}: ",
                                    style: AppStyle.fontMedium12,
                                  ),

                                  Text(
                                    "${entry['value']}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton(
                          onPressed: () async{
                            await bookService(widget.serviceId);
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
                            backgroundColor: AppColor.greenColor,
                          ),
                          child: Text(
                            "Book Service",
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