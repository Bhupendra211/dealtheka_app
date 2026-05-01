import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/views/user/book_service.dart';
import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../constant/AppStyle.dart';
import '../../constant/Colors.dart';

class SearchResult extends StatefulWidget {
  final String query;

  const SearchResult({super.key, required this.query});

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  Future<List<Map<String, dynamic>>> fetchSubmittedServicesForUser() async {
    try {
      final indexSnapshot =
          await FirebaseFirestore.instance.collection('index').where('status', isEqualTo: 'active').get();

      final matchedServiceIds = <String>{};
      final query = widget.query.trim().toLowerCase();
      final queryWords = query.split(RegExp(r'\s+'));

      for (var doc in indexSnapshot.docs) {
        final category = (doc['category'] ?? '').toString().toLowerCase();
        final location = (doc['location'] ?? '').toString().toLowerCase();

        double maxSimilarity = 0;

        for (var word in queryWords) {
          final categorySim = StringSimilarity.compareTwoStrings(
            category,
            word,
          );
          final locationSim = StringSimilarity.compareTwoStrings(
            location,
            word,
          );
          maxSimilarity = [
            maxSimilarity,
            categorySim,
            locationSim,
          ].reduce((a, b) => a > b ? a : b);
        }

        // Debug print
        print(
          'Checking "${doc['category']}" | "${doc['location']}" → Similarity: $maxSimilarity',
        );

        if (maxSimilarity >= 0.3) {
          matchedServiceIds.add(doc['serviceId']);
        }
      }

      if (matchedServiceIds.isEmpty) return [];

      final serviceDocs = await Future.wait(
        matchedServiceIds.map((id) {
          return FirebaseFirestore.instance
              .collection('submitted_services')
              .doc(id)
              .get();
        }),
      );

      return serviceDocs.where((doc) => doc.exists).map((doc) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error: $e");
      return [];
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
              services.map((service) {
                final attributes =
                    service['attributes'] as Map<String, dynamic>? ?? {};
                final location = service['location'] ?? 'Unknown';
                final category = service['category'] ?? 'Unknown';
                final image = service['imageUrl'] ?? '';

                return Container(
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
                              color: AppColor.primaryColor,
                            ),
                            SizedBox(width: screenHeight * 0.02),
                            Text(category, style: AppStyle.fontMedium),
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
                            SizedBox(width: screenHeight * 0.02),
                            Text(location, style: AppStyle.fontMedium12),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              image,
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
                              attributes.entries.take(5).map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  ),
                                );
                              }).toList(),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        BookService(serviceId: service['id']),
                              ),
                            );
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
                            "Get Details",
                            style: TextStyle(color: AppColor.whiteColor),
                          ),
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
