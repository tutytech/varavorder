import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/grplist.dart';
import 'package:orderapp/ledgerform.dart';
import 'package:orderapp/productlist.dart';
import 'dart:convert';

import 'package:orderapp/widgets/customappbar.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditGroup extends StatefulWidget {
  final String? rights, id;
  const EditGroup({Key? key, this.rights, this.id}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<EditGroup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Variable to hold dropdown selection
  String _selectedStatus = 'Active';
  List<Map<String, dynamic>> group = []; // Default selected status

  String? selectedBranch;
  String? selectedRights;
  String? selectedBranchName;
  bool isLoading = true;
  String? _staffId;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.id != null) {
      fetchgroups(widget.id!);
    } else {
      _showError('Invalid branch ID provided.');
    } // Fetch branches // Fetch branches when the widget dependencies change
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateGroups() async {
    print('---------------${widget.id}');
    try {
      final url = Uri.parse('https://varav.tutytech.in/group.php');

      final requestBody = {
        'type': 'update',
        'id': widget.id.toString(),

        'groupname': _groupNameController.text.trim(),
        'groupcode': _groupCodeController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      // Debugging prints
      debugPrint('Request URL: $url');
      debugPrint('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result[0]['status'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('group updated successfully!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Grouplist()),
          ); // Return to the previous screen
        } else {
          _showError(result[0]['message'] ?? 'Failed to update group.');
        }
      } else {
        _showError('Failed to update group: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error: $error');
      _showError('An error occurred: $error');
    }
  }

  Future<void> fetchgroups(String id) async {
    print('Fetching ledgers...');
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyid');

    // Ensure the companyId is not null or empty
    if (companyId == null || companyId.isEmpty) {
      throw Exception("Company ID is missing.");
    }
    const String _baseUrl = 'https://varav.tutytech.in/group.php';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'type': 'select', 'companyid': companyId},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        // Check if 'data' exists and is a list
        if (decodedResponse.containsKey('data') &&
            decodedResponse['data'] is List) {
          final List<dynamic> dataList = decodedResponse['data'];

          // Populate ledger list
          group =
              dataList
                  .map<Map<String, dynamic>>(
                    (scheme) => {
                      'id': scheme['id'].toString(),
                      'name': scheme['scheme'].toString(),
                    },
                  )
                  .toSet()
                  .toList();

          print('Groups: $group');

          // Extract the branch data by ID
          final branch = dataList.firstWhere(
            (branch) => branch['id'].toString() == id,
            orElse: () => null,
          );

          if (branch != null) {
            setState(() {
              _updateBranchFields(branch);
              isLoading = false;
            });
          } else {
            _showError('No branch found with ID $id.');
          }
        } else {
          _showError('Invalid response format: "data" is not a list.');
        }
      } else {
        _showError('Failed to fetch groups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showError('An error occurred while fetching groups.');
    }
  }

  void _updateBranchFields(Map<String, dynamic> branch) {
    print('Updating fields with branch data: $branch');

    _groupNameController.text = branch['groupname'] ?? '';
    _groupCodeController.text = branch['groupcode']?.toString() ?? '';
    _descriptionController.text = branch['description'] ?? '';
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
            MaterialPageRoute(builder: (context) => Grouplist()),
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
        title: 'Edit Group',
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
                                    _updateGroups();
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Grouplist(),
                                    ),
                                  );
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
