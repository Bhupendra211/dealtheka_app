import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../models/document_model.dart';

class DocumentUploadController {
  final picker = ImagePicker();
  final DocumentModel model = DocumentModel();

  // Replace with your actual Cloudinary credentials
  final String cloudName = 'dlnxmbal5';
  final String uploadPreset = 'dealtheka';

  Future<File?> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String?> uploadToCloudinary(File file) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final jsonRes = json.decode(resStr);
      return jsonRes['secure_url'];
    } else {
      print("Upload failed: ${response.statusCode}");
      return null;
    }
  }

  Future<bool> uploadAll() async {
    try {
      if (model.aadhaarFront != null) {
        try {
          final url = await uploadToCloudinary(model.aadhaarFront!);
          print('Aadhaar Front uploaded: $url');
        } catch (e) {
          print('Error uploading Aadhaar Front: $e');
        }
      }

      if (model.aadhaarBack != null) {
        try {
          final url = await uploadToCloudinary(model.aadhaarBack!);
          print('Aadhaar Back uploaded: $url');
        } catch (e) {
          print('Error uploading Aadhaar Back: $e');
        }
      }

      if (model.docFront != null) {
        try {
          final url = await uploadToCloudinary(model.docFront!);
          print('Doc Front uploaded: $url');
        } catch (e) {
          print('Error uploading Doc Front: $e');
        }
      }

      if (model.docBack != null) {
        try {
          final url = await uploadToCloudinary(model.docBack!);
          print('Doc Back uploaded: $url');
        } catch (e) {
          print('Error uploading Doc Back: $e');
        }
      }

      return true;
    } catch (e) {
      print('Unexpected error during upload: $e');
      return false;
    }
  }

}
