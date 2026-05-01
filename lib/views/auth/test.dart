import 'package:dealtheka/controllers/document_upload_controller.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class UploadDocumentsPage extends StatefulWidget {
  const UploadDocumentsPage({super.key});

  @override
  State<UploadDocumentsPage> createState() => _UploadDocumentsPageState();
}

class _UploadDocumentsPageState extends State<UploadDocumentsPage> {
  final controller = DocumentUploadController();

  Widget _buildUploadButton({
    required String label,
    required File? file,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
        if (file != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: const Icon(Icons.check_circle, color: Colors.green),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Decorative Circles
          ...List.generate(4, (index) {
            return Positioned(
              top: index < 2 ? -size.width * 0.65 : null,
              bottom: index >= 2 ? -size.width * 0.65 : null,
              left: index % 2 == 0 ? -size.width * 0.65 : null,
              right: index % 2 != 0 ? -size.width * 0.65 : null,
              child: CircleAvatar(
                radius: size.width * 0.5,
                backgroundColor: Colors.blue[800],
              ),
            );
          }),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: height * 0.05),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(height: height * 0.05),

                  // Upload Buttons
                  _buildUploadButton(
                    label: 'Upload Aadhaar Front Page',
                    file: controller.model.aadhaarFront,
                    onPressed: () async {
                      final img = await controller.pickImage();
                      if (img != null) {
                        setState(() {
                          controller.model.aadhaarFront = img;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildUploadButton(
                    label: 'Upload Aadhaar Back Page',
                    file: controller.model.aadhaarBack,
                    onPressed: () async {
                      final img = await controller.pickImage();
                      if (img != null) {
                        setState(() {
                          controller.model.aadhaarBack = img;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildUploadButton(
                    label: 'Upload Document Front Page (Optional)',
                    file: controller.model.docFront,
                    onPressed: () async {
                      final img = await controller.pickImage();
                      if (img != null) {
                        setState(() {
                          controller.model.docFront = img;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildUploadButton(
                    label: 'Upload Document Back Page (Optional)',
                    file: controller.model.docBack,
                    onPressed: () async {
                      final img = await controller.pickImage();
                      if (img != null) {
                        setState(() {
                          controller.model.docBack = img;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: controller.model.isAadhaarComplete
                        ? () async {
                      await controller.uploadAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Documents uploaded!")),
                      );
                    }
                        : null,
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
