import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dealtheka/models/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/service_model.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all users with role 'user'
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching users: $e");
      return [];
    }
  }

  /// Fetch all users with role 'user'
  Future<List<UserModel>> getAllServiceProvider() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'service provider')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching users: $e");
      return [];
    }
  }

  /// Delete a user by ID
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
      Fluttertoast.showToast(msg: "User deleted successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to delete user: $e");
    }
  }

  /// Update a user with new data
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
      Fluttertoast.showToast(msg: "User updated successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update user: $e");
    }
  }
}

class ServiceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'services';

  // ✅ Get all services
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final snapshot = await _firestore.collection('services').get();
      return snapshot.docs.map((doc) {
        return ServiceModel.fromJson(doc.data(), doc.id); // Pass doc.id as the second argument
      }).toList();
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to fetch services: $e");
      return [];
    }
  }

  // ✅ Add service
  Future<void> addService(ServiceModel service) async {
    try {
      await _firestore.collection(_collectionPath).add(service.toJson());
      Fluttertoast.showToast(msg: "Service added successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to add service: $e");
    }
  }

  // ✅ Update service
  Future<void> updateService(String id, ServiceModel service) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).update(service.toJson());
      Fluttertoast.showToast(msg: "Service updated successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update service: $e");
    }
  }

  // ✅ Delete service
  Future<void> deleteService(String id) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).delete();
      Fluttertoast.showToast(msg: "Service deleted successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to delete service: $e");
    }
  }


  Future<String?> getLoggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }


  Future<Map<String, int>> getTotalCancelledBookingsForLoggedInUser() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String? loggedInUserId = await getLoggedInUserId(); // Assume this gets from SharedPreferences

    if (loggedInUserId == null) return {};

    final bookingsSnapshot = await firestore.collection('bookings').get();

    Map<String,int> totalCount= {};

    int cancelledCount = 0, pending=0,success=0,total=0;

    for (var bookingDoc in bookingsSnapshot.docs) {
      final bookingData = bookingDoc.data();
      final indexId = bookingData['index_id'];

      // Fetch corresponding index document
      final indexDoc = await firestore.collection('index').doc(indexId).get();
      if (indexDoc.exists) {
        final indexData = indexDoc.data();

        // Check if booking belongs to the current logged-in user and is cancelled
        if (indexData != null &&
            indexData['userUid'] == loggedInUserId &&
            bookingData['status'] == 'Cancelled') {
          cancelledCount++;
          total++;
        }else if (indexData != null &&
            indexData['userUid'] == loggedInUserId &&
            bookingData['status'] == 'Pending') {
          pending++;
          total++;
        }else if (indexData != null &&
            indexData['userUid'] == loggedInUserId) {
          total++;
          success++;
        }
      }
    }

    totalCount['cancel']=cancelledCount;
    totalCount['pending']=pending;
    totalCount['success']=success;
    totalCount['total']=total;


    return totalCount;
  }

}
