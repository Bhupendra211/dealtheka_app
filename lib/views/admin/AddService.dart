import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/constant/icon_list.dart';
import 'package:dealtheka/controllers/service_controller.dart';
import 'package:dealtheka/models/service_model.dart';
import 'package:dealtheka/widgets/footer.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';


class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddService> {
  final _controller = ServiceController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController iconController = TextEditingController();

  List<Map<String, String>> dynamicAttributes = List.generate(10, (_) => {
    'name': '',
    'type': 'String',
  });

  final List<String> valueTypes = ['String', 'Number'];

  void submitService() async{
    LoadingDialog.show(context);
    final filteredAttributes = dynamicAttributes.where((attribute) => attribute['name']?.isNotEmpty ?? false).toList();
    final service = ServiceModel(
      name: nameController.text,
      category: categoryController.text,
      icon: iconController.text,
      attributes: filteredAttributes,
    );

    bool response= await _controller.addService(service);

    if(response){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service added successfully')),
      );
      nameController.clear();
      categoryController.clear();
      iconController.clear();

      dynamicAttributes = List.generate(10, (_) => {'name': '', 'type': 'String'});
      LoadingDialog.hide(context);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add service. Please try again.')),
      );
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
        title: Text("New Services", style: AppStyle.fontMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                  child: Text("Add New Services", style: AppStyle.fontMedium)),
              SizedBox(height: 16),

              _inputField("Enter your Service Name", nameController),
              _inputField("Select Service Category", categoryController),
              _iconDropdown(),

              SizedBox(height: screenHeight*0.02),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Add Dynamic Attributes", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: screenHeight*0.02),

              ...List.generate(10, (index) {
                return Padding(
                  padding:  EdgeInsets.symmetric(vertical: screenHeight*0.01),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Attribute Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.0)
                            ),
                          ),
                          onChanged: (value) => dynamicAttributes[index]['name'] = value,
                        ),
                      ),
                      SizedBox(width: screenWidth*0.02),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: dynamicAttributes[index]['type'],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0)
                            ),
                          ),
                          items: valueTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() {
                            dynamicAttributes[index]['type'] = value!;
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: submitService,
                label: Text("Add"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),

              SizedBox(height: 40),
              AppFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _iconDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: iconController.text.isNotEmpty ? iconController.text : null,
        decoration: InputDecoration(
          hintText: 'Select Service Icon',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        items: iconList.map((iconData) {
          return DropdownMenuItem<String>(
            value: iconData['name'],
            child: Row(
              children: [
                Icon(iconData['icon'], size: 20),
                SizedBox(width: 10),
                Text(iconData['name']),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            iconController.text = value!;
          });
        },
      ),
    );
  }

}
