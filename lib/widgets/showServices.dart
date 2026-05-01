import 'package:dealtheka/constant/icon_list.dart';
import 'package:dealtheka/controllers/dashboard_controller.dart';
import 'package:dealtheka/models/service_model.dart';
import 'package:dealtheka/widgets/adminPacks/serviceBox.dart';
import 'package:flutter/material.dart';

class ShowServices extends StatelessWidget {
  final ServiceController _service = ServiceController();
  final void Function(ServiceModel)? onServiceTap;

  ShowServices({super.key, this.onServiceTap});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<ServiceModel>>(
      future: _service.getAllServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No services found"));
        }

        final services = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(
              (services.length / 2).ceil(),
                  (rowIndex) {
                final firstIndex = rowIndex * 2;
                final secondIndex = firstIndex + 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ServiceBox(
                          text: services[firstIndex].category ?? 'Unnamed',
                          icon: getIconFromName(services[firstIndex].icon),
                          onTap: () {
                            if (onServiceTap != null) {
                              onServiceTap!(services[firstIndex]);
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/search-detail',
                                arguments: services[firstIndex].category,
                              );
                            }
                          },
                        ),
                      ),

                      const SizedBox(width: 20),

                      // If odd number of items
                      if (secondIndex < services.length)
                        Expanded(
                          child: ServiceBox(
                            text: services[secondIndex].category ?? 'Unnamed',
                            icon: getIconFromName(services[secondIndex].icon),
                            onTap: () {
                              if (onServiceTap != null) {
                                onServiceTap!(services[secondIndex]);
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  '/search-detail',
                                  arguments: services[secondIndex].category,
                                );
                              }
                            },
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

IconData getIconFromName(String name) {
  // Find the icon in the list by matching the name
  final iconData = iconList.firstWhere(
    (icon) => icon['name'] == name,
    orElse: () => {'icon': Icons.help}, // Default icon if not found
  );

  return iconData['icon'];
}
