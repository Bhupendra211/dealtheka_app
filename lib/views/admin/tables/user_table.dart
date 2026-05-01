import 'package:dealtheka/constant/AppStyle.dart';
import 'package:dealtheka/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:dealtheka/controllers/dashboard_controller.dart';
import 'package:dealtheka/models/user_model.dart';

class UserTablePage extends StatefulWidget {
  const UserTablePage({super.key});

  @override
  State<UserTablePage> createState() => _UserTablePageState();
}

class _UserTablePageState extends State<UserTablePage> {
  final UserController _controller = UserController();
  List<UserModel> users = [];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    setState(() => _isLoading = true);
    final data = await _controller.getAllUsers(); // Assumes filtering by role = 'user'
    setState(() {
      users = data;
      _isLoading = false;
    });
  }

  void _deleteUser(String id) async {
    LoadingDialog.show(context);
    await _controller.deleteUser(id);
    LoadingDialog.hide(context);
    _fetchUsers();
  }

  void _editUser(UserModel user) {
    TextEditingController nameCtrl = TextEditingController(text: user.name);
    TextEditingController emailCtrl = TextEditingController(text: user.email);
    TextEditingController numberCtrl = TextEditingController(text: user.number);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: numberCtrl, decoration: const InputDecoration(labelText: 'Number')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                LoadingDialog.show(context);
                await _controller.updateUser(
                  UserModel(
                    id: user.id,
                    name: nameCtrl.text,
                    email: emailCtrl.text,
                    number: numberCtrl.text,
                  ),
                );
                LoadingDialog.hide(context);
                Navigator.pop(context);
                _fetchUsers();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text("Users Table", style: AppStyle.fontMedium),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text("No user found."))
          : SingleChildScrollView(
        child: PaginatedDataTable(
          rowsPerPage: _rowsPerPage,
          availableRowsPerPage: const [5, 10, 20],
          onRowsPerPageChanged: (value) {
            if (value != null) setState(() => _rowsPerPage = value);
          },
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Number')),
            DataColumn(label: Text('Actions')),
          ],
          source: _UserDataSource(users, _editUser, _deleteUser),
        ),
      ),
    );
  }
}


class _UserDataSource extends DataTableSource {
  final List<UserModel> users;
  final void Function(UserModel) onEdit;
  final void Function(String) onDelete;

  _UserDataSource(this.users, this.onEdit, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    return DataRow(cells: [
      DataCell(Text(user.name)),
      DataCell(Text(user.email)),
      DataCell(Text(user.number)),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: () => onEdit(user),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(user.id),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}
