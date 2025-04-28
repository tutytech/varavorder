import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/ledgerform.dart';
import 'package:orderapp/productlist.dart';
import 'dart:convert';

import 'package:orderapp/widgets/customappbar.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateGroup extends StatefulWidget {
  final String? rights;
  const CreateGroup({Key? key, this.rights}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<CreateGroup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Variable to hold dropdown selection
  String _selectedStatus = 'Active'; // Default selected status

  String? selectedBranch;
  String? selectedRights;
  String? selectedBranchName;
  String? _staffId;
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   fetchBranches(); // Fetch branches when the widget dependencies change
  // }

  Future<List<Map<String, dynamic>>> fetchBranches() async {
    const String apiUrl = 'https://chits.tutytech.in/branch.php';

    try {
      // Print the request URL
      print('Request URL: $apiUrl');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'select'},
      );

      // Print the response body
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as List<dynamic>;

        return responseData.map((branch) {
          return {
            'id': branch['id'] ?? '',
            'branchname': branch['branchname'] ?? 'Unknown Branch',
            'openingbalance': branch['openingbalance']?.toString() ?? '0',
            'openingdate': branch['openingdate'] ?? 'N/A',
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch branches');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> _creategroup() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final String? companyId = prefs.getString('companyid');

    // Check if the userId or companyId is null
    if (userId == null || companyId == null) {
      _showSnackBar('User ID or Company ID is missing.');
      return;
    }

    // Check if the form is valid
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Exit the method if validation fails
    }

    final String apiUrl = 'https://varav.tutytech.in/group.php';

    try {
      // Print the request URL and body for debugging
      print('Request URL: $apiUrl');
      print(
        'Request body: ${{'type': 'insert', 'groupname': _groupNameController.text, 'groupcode': _groupCodeController.text, 'description': _descriptionController.text}}',
      );

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'type': 'insert',
          'groupname': _groupNameController.text,
          'groupcode': _groupCodeController.text,
          'description': _descriptionController.text,

          'entryid': userId,
          'companyid': companyId,
        },
      );

      // Check if the response body is empty
      if (response.body.isEmpty) {
        _showSnackBar('Received empty response from server.');
        return;
      }

      // Print the response body for debugging
      print('Response body: ${response.body}');

      // Attempt to decode the response body
      try {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('id')) {
          _showSnackBar('Group created successfully');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Ledger()),
          );
        } else if (responseData.containsKey('error')) {
          _showSnackBar('Error: ${responseData['error']}');
        }
      } catch (e) {
        _showSnackBar('Failed to parse response as JSON. Error: $e');
      }
    } catch (e) {
      // Print the error for debugging
      print('Error: $e');
      _showSnackBar('An error occurred: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: 'Create Group',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      body: Stack(
        children: [
          Container(color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _groupNameController,
                        label: 'Group Name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Group name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _groupCodeController,
                        label: 'Group Code',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Group code is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _creategroup();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomerSearchPage()),
            );
          },
          child: const Icon(Icons.group, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(onItemSelected: (int) {}),
    );
  }

  // Custom TextField with Box Shadow
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    int maxLines = 1, // <-- Added this line
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines, // <-- Added this line
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
