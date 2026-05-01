import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiceProviderController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final picker = ImagePicker();

  // Replace with your actual Cloudinary credentials
  final String cloudName = 'dlnxmbal5';
  final String uploadPreset = 'dealtheka';

  Future<File?> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<ServiceModel?> getServiceById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('services').doc(id).get();
      if (doc.exists) {
        return ServiceModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // In ServiceProviderController
  Future<bool> submitForm(
    String serviceId,
    String category,
    String location,
    Map<String, TextEditingController> valueControllers,
    File? uploadedImage,
  ) async {
    try {
      // Prepare the data
      Map<String, dynamic> submittedData = {
        'serviceId': serviceId,
        'category': category,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
      };

      Map<String, dynamic> attributes = {};
      valueControllers.forEach((name, controller) {
        attributes[name] = controller.text;
      });
      submittedData['attributes'] = attributes;

      // Step 1: Upload the image if provided
      if (uploadedImage != null) {
        final cloudinaryUrl = Uri.parse(
          "https://api.cloudinary.com/v1_1/dlnxmbal5/image/upload",
        );
        final uploadPreset = "dealtheka";

        final request =
            http.MultipartRequest('POST', cloudinaryUrl)
              ..fields['upload_preset'] = uploadPreset
              ..files.add(
                await http.MultipartFile.fromPath('file', uploadedImage.path),
              );

        final response = await request.send();

        if (response.statusCode == 200) {
          final respData = await response.stream.bytesToString();
          final jsonResp = json.decode(respData);
          final imageUrl = jsonResp['secure_url'];
          final imageName = jsonResp['original_filename'];

          // Step 2: Add image URL or name to submittedData
          submittedData['imageUrl'] = imageUrl;
          submittedData['imageName'] = imageName;
        } else {
          print("Image upload failed: ${response.statusCode}");
        }
      }

      // Step 3: Save the submitted data to Firestore under 'submitted_services' collection
      DocumentReference serviceRef = await _firestore
          .collection('submitted_services')
          .add(submittedData);
      print("Form submitted successfully");

      // Step 4: Get the current user's UID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userUid = prefs.getString('uid');

      if (userUid != null) {
        // Step 5: Create a new entry in the 'index' collection with the necessary details
        Map<String, dynamic> indexData = {
          'serviceId':
              serviceRef.id, // Using the service ID generated from Firestore
          'userUid': userUid, // User's UID
          'category': category,
          'location': location,
          'status': 'active', // Default status
          'timestamp': FieldValue.serverTimestamp(), // Timestamp
        };

        // Save the index data to the 'index' collection
        await _firestore.collection('index').add(indexData);
        return true;
      } else {
        print("User UID not found in shared preferences.");
        Fluttertoast.showToast(msg:"User UID not found. Login Again");
        return false;
      }
    } catch (e) {
      print("Error submitting form: $e");
      Fluttertoast.showToast(msg:"Something went wrong");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSubmittedServicesForUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userUid = prefs.getString('uid');

    if (userUid == null) {
      Fluttertoast.showToast(msg:"User UID not found. Login Again");
      return [];
    }

    try {
      // Step 1: Get all index documents for current user
      final indexSnapshot =
          await FirebaseFirestore.instance
              .collection('index')
              .where('userUid', isEqualTo: userUid)
              .get();

      List<Map<String, dynamic>> servicesData = [];

      // Step 2: For each index doc, fetch submitted_service by serviceId
      for (var indexDoc in indexSnapshot.docs) {
        final serviceId = indexDoc['serviceId'];

        final serviceDoc =
            await FirebaseFirestore.instance
                .collection('submitted_services')
                .doc(serviceId)
                .get();

        if (serviceDoc.exists) {
          servicesData.add(serviceDoc.data()!);
        }
      }

      return servicesData;
    } catch (e) {
      print("Error fetching submitted services: $e");
      return [];
    }
  }


  Future<Map<String, dynamic>?> getCreateServiceById(String id) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection('submitted_services').doc(id).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // optionally add the document ID
        return data;
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<bool> updateService(
      String createdServiceId,
      String serviceId,
      String location,
      Map<String, TextEditingController> valueControllers,
      File? image,
      ) async {
    try {
      // Step 1: Build attributes map
      Map<String, dynamic> attributes = {};
      valueControllers.forEach((key, controller) {
        attributes[key] = controller.text;
      });

      // Step 2: Prepare the update data
      Map<String, dynamic> updateData = {
        'location': location,
        'attributes': attributes,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Step 3: If new image is provided, upload it and update imageUrl and imageName
      if (image != null) {
        final cloudinaryUrl =
        Uri.parse("https://api.cloudinary.com/v1_1/dlnxmbal5/image/upload");
        final uploadPreset = "dealtheka";

        final request = http.MultipartRequest('POST', cloudinaryUrl)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath('file', image.path));

        final response = await request.send();

        if (response.statusCode == 200) {
          final respData = await response.stream.bytesToString();
          final jsonResp = json.decode(respData);
          final imageUrl = jsonResp['secure_url'];
          final imageName = jsonResp['original_filename'];

          updateData['imageUrl'] = imageUrl;
          updateData['imageName'] = imageName;
        } else {
          print("Image upload failed: ${response.statusCode}");
          Fluttertoast.showToast(msg: "Image upload failed");
          return false;
        }
      }

      // Step 4: Update the submitted_services collection
      await _firestore.collection('submitted_services').doc(createdServiceId).update(updateData);
      print("Service updated successfully in submitted_services");

      // Step 5: Update the related document in the 'index' collection
      final indexSnapshot = await _firestore
          .collection('index')
          .where('serviceId', isEqualTo: serviceId)
          .get();

      for (final doc in indexSnapshot.docs) {
        await doc.reference.update({
          'location': location,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print("Error updating service: $e");
      Fluttertoast.showToast(msg: "Error updating service");
      return false;
    }
  }



// Existing methods like getAllServices()
}
