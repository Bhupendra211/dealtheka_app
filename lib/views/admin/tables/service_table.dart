import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/controllers/dashboard_controller.dart';
import 'package:dealtheka/models/service_model.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ServiceTableView extends StatefulWidget {
  const ServiceTableView({super.key});

  @override
  State<ServiceTableView> createState() => _ServiceTableViewState();
}

class _ServiceTableViewState extends State<ServiceTableView> {
  final ServiceController _controller = ServiceController();
  List<ServiceModel> services = [];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  void _fetchServices() async {
    final data = await _controller.getAllServices();
    setState(() => services = data);
  }

  void _deleteService(String id) async {
    LoadingDialog.show(context);
    await _controller.deleteService(id);
    LoadingDialog.hide(context);
    _fetchServices();
  }

  void _editService(ServiceModel service, String id) {
    TextEditingController nameCtrl = TextEditingController(text: service.name);
    TextEditingController categoryCtrl = TextEditingController(text: service.category);
    TextEditingController iconCtrl = TextEditingController(text: service.icon);
    List<Map<String, String>> attributes = List.from(service.attributes);

    // State to track number of attributes
    int attributeCount = attributes.length;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category')),
                TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Icon')),
                const SizedBox(height: 10),

                // Display existing attributes and allow adding new ones
                ...List.generate(10, (i) {
                  if (i >= attributes.length) {
                    // Add new empty attributes if there are less than 10
                    attributes.add({"name": "", "type": "String"});
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Attribute ${i + 1}'),
                          onChanged: (val) => attributes[i]['name'] = val,
                          controller: TextEditingController(text: attributes[i]['name']),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: attributes[i]['type'],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => attributes[i]['type'] = val);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'String', child: Text('String')),
                          DropdownMenuItem(value: 'Number', child: Text('Number')),
                        ],
                      ),
                    ],
                  );
                }),

                // Button to add more attributes
                if (attributeCount < 10)
                  ElevatedButton(
                    onPressed: () {
                      setDialogState(() {
                        // Add new attribute
                        if (attributeCount < 10) {
                          attributes.add({"name": "", "type": "String"});
                          attributeCount++;
                        }
                      });
                    },
                    child: const Text('Add Attribute'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                LoadingDialog.show(context);

                // Filter out attributes with empty names
                List<Map<String, String>> validAttributes = attributes.where((attribute) {
                  return attribute['name']?.isNotEmpty ?? false;
                }).toList();

                // Update the service only if valid attributes exist
                if (validAttributes.isNotEmpty) {
                  await _controller.updateService(
                    id,
                    ServiceModel(
                      name: nameCtrl.text,
                      category: categoryCtrl.text,
                      icon: iconCtrl.text,
                      attributes: validAttributes,
                    ),
                  );

                  // Update the service locally after the update
                  final updatedService = ServiceModel(
                    name: nameCtrl.text,
                    category: categoryCtrl.text,
                    icon: iconCtrl.text,
                    attributes: validAttributes,
                  );

                  setState(() {
                    // Replace the updated service in the list
                    int index = services.indexWhere((service) => service.id == id);
                    if (index != -1) {
                      services[index] = updatedService;
                    }
                  });
                } else {
                  // Show a toast or alert if no valid attributes are available
                  Fluttertoast.showToast(msg: "Please provide valid attribute names.");
                }

                Navigator.pop(context);
                LoadingDialog.hide(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const BackButton(color: Colors.black),
      title: Text("Service Table", style: AppStyle.fontMedium),
      centerTitle: true,
    ),
      body: services.isEmpty
          ? const Center(child: Text("No services found."))
          : SingleChildScrollView(
        child: PaginatedDataTable(
          rowsPerPage: _rowsPerPage,
          availableRowsPerPage: const [5, 10, 20],
          onRowsPerPageChanged: (value) {
            if (value != null) setState(() => _rowsPerPage = value);
          },
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Icon')),
            DataColumn(label: Text('Actions')),
          ],
          source: _ServiceDataSource(services, _editService, _deleteService),
        ),
      ),
    );
  }
}

class _ServiceDataSource extends DataTableSource {
  final List<ServiceModel> services;
  final void Function(ServiceModel, String) onEdit;
  final void Function(String) onDelete;

  _ServiceDataSource(this.services, this.onEdit, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= services.length) return null;
    final service = services[index];

    return DataRow(cells: [
      DataCell(Text(service.name)),
      DataCell(Text(service.category)),
      DataCell(Text(service.icon)),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: () => onEdit(service, service.id ?? ''),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(service.id ?? ''),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => services.length;
  @override
  int get selectedRowCount => 0;
}