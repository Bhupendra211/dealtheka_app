import 'package:dealtheka/controllers/document_upload_controller.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';

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
        ElevatedButton(onPressed: onPressed, child: Text(label)),
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
          Positioned(
            top: -size.width * 0.65,
            left: -size.width * 0.65,
            child: CircleAvatar(
              radius: size.width * 0.5,
              backgroundColor: Colors.blue[800],
            ),
          ),
          Positioned(
            top: -size.width * 0.65,
            right: -size.width * 0.65,
            child: CircleAvatar(
              radius: size.width * 0.5,
              backgroundColor: Colors.blue[800],
            ),
          ),
          Positioned(
            bottom: -size.width * 0.65,
            left: -size.width * 0.65,
            child: CircleAvatar(
              radius: size.width * 0.5,
              backgroundColor: Colors.blue[800],
            ),
          ),
          Positioned(
            bottom: -size.width * 0.65,
            right: -size.width * 0.65,
            child: CircleAvatar(
              radius: size.width * 0.5,
              backgroundColor: Colors.blue[800],
            ),
          ),
          Column(
            children: [
              // Push logo a bit above
              SizedBox(height: height * 0.1),

              Image.asset('assets/images/logo.png', width: 150, height: 150),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.07),

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
                      SizedBox(height: height * 0.025),
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
                      SizedBox(height: height * 0.025),
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
                      SizedBox(height: height * 0.025),
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

                      SizedBox(height: height * 0.04),

                      ElevatedButton(
                        onPressed:
                            controller.model.isAadhaarComplete
                                ? () async {
                                  LoadingDialog.show(context);
                                  bool response = await controller.uploadAll();

                                  if (response) {
                                    LoadingDialog.hide(context);
                                    Fluttertoast.showToast(
                                      msg: "Document Uploaded successfully",
                                    );
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/',
                                    );
                                  } else {
                                    LoadingDialog.hide(context);
                                    Fluttertoast.showToast(
                                      msg:
                                          "Something went wrong. We can't upload document.",
                                    );
                                  }
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
        ],
      ),
    );
  }
}
