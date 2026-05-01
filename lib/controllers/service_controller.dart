import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_model.dart';
import 'package:flutter/material.dart';
class ServiceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addService(ServiceModel service) async {
    try{
      await _firestore.collection('services').add(service.toJson());
      return true;
    }catch(e){
     print("ERROR IS: $e");
     return false;
    }
  }



}
