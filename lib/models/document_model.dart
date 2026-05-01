import 'dart:io';

class DocumentModel {
  File? aadhaarFront;
  File? aadhaarBack;
  File? docFront;
  File? docBack;

  bool get isAadhaarComplete => aadhaarFront != null && aadhaarBack != null;
}
