import 'package:dealtheka/views/serviceProvider/Service/create_service.dart';
import 'package:dealtheka/widgets/showServices.dart';
import 'package:flutter/material.dart';

class SelectCategory extends StatefulWidget {
  const SelectCategory({super.key});

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  String? _selectedInterest;

  // Mapping between UI text and DB values
  final Map<String, String> roleMap = {
    'Customer': 'user',
    'Services Provider': 'service provider',
  };

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
              SizedBox(height: height * 0.1),
              Image.asset('assets/images/logo.png', width: 150, height: 150),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.1),
                      ShowServices(
                        onServiceTap: (service) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => CreateService(
                                    serviceId: service.id.toString(),
                                  ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: height * 0.05),

                      // Button
                      ElevatedButton(
                        onPressed: () => {Navigator.pop(context)},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(color: Colors.white),
                        ),
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
