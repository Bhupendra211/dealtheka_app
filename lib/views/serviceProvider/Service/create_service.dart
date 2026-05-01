import 'dart:io';
import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/constant/Colors.dart';
import 'package:dealtheka/constant/icon_list.dart';
import 'package:dealtheka/controllers/service_provider_controller.dart';
import 'package:dealtheka/widgets/custom_button.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/service_model.dart';

class CreateService extends StatefulWidget {
  final String serviceId;

  const CreateService({super.key, required this.serviceId});

  @override
  State<CreateService> createState() => _CreateServiceState();
}

class _CreateServiceState extends State<CreateService> {
  final ServiceProviderController _controller = ServiceProviderController();
  File? uploadedImage;
  // Controller for location and dynamic attribute values
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
    final service = await _controller.getServiceById(widget.serviceId);
    if (service != null) {
      setState(() {
        _service = service;
        _isLoading = false;
        // Initialize the controllers for attributes only once
        for (var attr in service.attributes) {
          valueControllers[attr['name']!] = TextEditingController();
        }
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
        title: Text("Create New Service", style: AppStyle.fontMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: ClipOval(
                  child: Ink.image(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                    height: screenWidth * 0.4,
                    width: screenWidth * 0.4,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Check if the service data is loaded
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              if (_service != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: TextEditingController(text: _service!.category),
                      decoration: InputDecoration(
                        prefixIcon: Icon(getIconFromName(_service!.icon), size: 40, color: AppColor.primaryColor),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.01,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        prefixStyle: AppStyle.fontMedium,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      enabled: false,
                    ),


                    const SizedBox(height: 20),

                    // TextField for Location (if type is string)
                    if (_service!.attributes.any(
                          (attr) => attr['type'] == 'String',
                    ))
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
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: screenHeight * 0.015),

                    // Loop through attributes and create fields for name and value
                    for (var attr in _service!.attributes)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Name TextField (static, it just displays the name)
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                  text: attr['name'],
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Name',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05,
                                    vertical: screenHeight * 0.01,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                enabled: false,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),

                            // Value TextField (dynamic based on type)
                            Expanded(
                              child: TextField(
                                controller: valueControllers[attr['name']!],
                                keyboardType:
                                attr['type'] == 'Number'
                                    ? TextInputType.number
                                    : TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Enter value',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05,
                                    vertical: screenHeight * 0.01,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: screenHeight * 0.025),

                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
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
                            label: const Text("Upload Service Profile"),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (uploadedImage != null)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    Center(
                      child: CustomButton(
                        text: "Create Service",
                        onPressed: () async{
                          LoadingDialog.show(context);
                         bool response= await _controller.submitForm(
                            _service!.id!,
                            _service!.category,
                            locationController.text,
                            valueControllers,
                            uploadedImage, // pass the image to controller
                          );

                          LoadingDialog.hide(context);
                          if(response){
                            Fluttertoast.showToast(msg: "Service created successfully");
                          locationController.text='';
                            valueControllers.forEach((key, controller) {
                              controller.clear();
                            });
                            uploadedImage=null;
                        }

                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData getIconFromName(String name) {
    // Find the icon in the list by matching the name
    final iconData = iconList.firstWhere(
          (icon) => icon['name'] == name,
      orElse: () => {'icon': Icons.help}, // Default icon if not found
    );

    return iconData['icon'];
  }
}

