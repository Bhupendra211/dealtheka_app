import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/constant/Colors.dart';
import 'package:dealtheka/views/serviceProvider/Service/edit_service.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyServices extends StatefulWidget {
  const MyServices({super.key});

  @override
  State<MyServices> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {
  Future<List<Map<String, dynamic>>> fetchSubmittedServicesForUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userUid = prefs.getString('uid');

    if (userUid == null) return [];

    try {
      final indexSnapshot =
          await FirebaseFirestore.instance
              .collection('index')
              .where('userUid', isEqualTo: userUid)
              .get();

      final serviceIds =
          indexSnapshot.docs.map((doc) => doc['serviceId']).toList();

      // Use Future.wait to fetch all service documents in parallel
      final serviceDocs = await Future.wait(
        serviceIds.map((id) {
          return FirebaseFirestore.instance
              .collection('submitted_services')
              .doc(id)
              .get();
        }),
      );

      return serviceDocs
          .where((doc) => doc.exists)
          .map((doc) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      })
          .toList();
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Future<bool> deleteService(String serviceId) async {
    try {
      // Delete from submitted_services
      await FirebaseFirestore.instance
          .collection('submitted_services')
          .doc(serviceId)
          .delete();

      // Delete all index entries with that serviceId
      final indexSnapshot =
          await FirebaseFirestore.instance
              .collection('index')
              .where('serviceId', isEqualTo: serviceId)
              .get();

      for (var doc in indexSnapshot.docs) {
        await doc.reference.delete();
      }

      // Optionally refresh the state/UI
      setState(() {});

      return true;
    } catch (e) {
      print('Error deleting service: $e');

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchSubmittedServicesForUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No services found."));
        }

        final services = snapshot.data!;

        return Column(
          children:
              services.map((service) {
                final attributes =
                    service['attributes'] as Map<String, dynamic>? ?? {};
                final location = service['location'] ?? 'Unknown';
                final category = service['category'] ?? 'Unknown';
                final image= service['imageUrl'] ??'';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: AppColor.primaryColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            image,
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, color: Colors.red);
                            },
                          ),
                        ),

                        SizedBox(width: screenWidth*0.05),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_taxi,
                                  color: AppColor.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(category, style: AppStyle.fontMedium),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Location: $location",
                              style: AppStyle.fontMedium12,
                            ),
                            const SizedBox(height: 4),
                            ...attributes.entries.map((entry) {
                              return Row(
                                children: [
                                  Text(
                                    "${entry.key}: ",
                                    style: AppStyle.fontMedium12,
                                  ),
                                  Text(
                                    "${entry.value}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            }),

                            Row(
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppColor.greenColor,
                                    foregroundColor: AppColor.whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () {
                                  //   EditService
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => EditService(serviceId: service['id']),
                                    ));
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text("Edit"),
                                    ],
                                  ),
                                ),

                                SizedBox(width: screenWidth*0.02),

                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppColor.redColor,
                                    foregroundColor: AppColor.whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () async{
                                    LoadingDialog.show(context);
                                    bool isDelete= await deleteService(service['id'] ?? '');

                                    if(isDelete){
                                      Fluttertoast.showToast(msg: "Service Deteled Successfully");
                                    }else{
                                      Fluttertoast.showToast(msg: "Service Deteled Successfully");
                                    }
                                    LoadingDialog.hide(context);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text("Delete"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
