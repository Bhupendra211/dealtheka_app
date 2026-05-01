import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../constant/AppStyle.dart';
import '../../../constant/Colors.dart';
import '../../../constant/icon_list.dart';
import '../../../controllers/service_provider_controller.dart';
import '../../../models/service_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_dialog.dart';


class EditService extends StatefulWidget {
  final String serviceId;

  const EditService({super.key, required this.serviceId});

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  final ServiceProviderController _controller = ServiceProviderController();
  File? uploadedImage;
  final TextEditingController locationController = TextEditingController();
  Map<String, TextEditingController> valueControllers = {};
  ServiceModel? _service;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServiceData();
  }

  Future<void> _fetchServiceData() async {
    final service = await _controller.getCreateServiceById(widget.serviceId);
    print("service: $service");

    if (service != null) {
      final baseService = await _controller.getServiceById(service['serviceId']);

      final Map<String, TextEditingController> tempControllers = {};
      final Map<String, dynamic> attributes = Map<String, dynamic>.from(service['attributes']);

      attributes.forEach((name, value) {
        tempControllers[name] = TextEditingController(text: value ?? '');
      });

      setState(() {
        _service = baseService;
        _isLoading = false;
        locationController.text = service["location"] ?? '';
        valueControllers = tempControllers;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text("Edit Service", style: AppStyle.fontMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: ClipOval(
                  child: Ink.image(
                    image: uploadedImage != null
                        ? FileImage(uploadedImage!)
                        : AssetImage('assets/images/logo.png')
                    as ImageProvider,
                    fit: BoxFit.cover,
                    height: screenWidth * 0.4,
                    width: screenWidth * 0.4,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Category field (non-editable)
              TextField(
                controller:
                TextEditingController(text: _service!.category),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    getIconFromName(_service!.icon),
                    size: 40,
                    color: AppColor.primaryColor,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                enabled: false,
              ),

              const SizedBox(height: 20),

              // Location
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    hintText: 'Enter your location',
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: AppColor.primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.015),

              // Dynamic Attribute Value Fields
              for (var attr in _service!.attributes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name (non-editable)
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                            text: attr['name'],
                          ),
                          decoration: InputDecoration(
                            hintText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          enabled: false,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      // Editable value
                      Expanded(
                        child: TextField(
                          controller: valueControllers[attr['name']!],
                          keyboardType: attr['type'] == 'Number'
                              ? TextInputType.number
                              : TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Enter value',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Image Upload
              ElevatedButton.icon(
                onPressed: () async {
                  final image = await _controller.pickImage();
                  if (image != null) {
                    setState(() {
                      uploadedImage = image;
                    });
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: const Text("Change Service Image"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (uploadedImage != null)
                const Icon(Icons.check_circle, color: Colors.green),

              const SizedBox(height: 20),

              // Submit Button
              CustomButton(
                text: "Update Service",
                onPressed: () async {
                  LoadingDialog.show(context);

                  bool response = await _controller.updateService(
                    widget.serviceId,
                    _service!.id!,
                    locationController.text,
                    valueControllers,
                    uploadedImage,
                  );

                  LoadingDialog.hide(context);
                  if (response) {
                    Fluttertoast.showToast(
                        msg: "Service updated successfully");
                  } else {
                    Fluttertoast.showToast(
                        msg: "Something went wrong");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData getIconFromName(String name) {
    final iconData = iconList.firstWhere(
          (icon) => icon['name'] == name,
      orElse: () => {'icon': Icons.help},
    );
    return iconData['icon'];
  }
}
