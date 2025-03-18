import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:orderapp/widgets/customappbar.dart';
import 'package:orderapp/widgets/customnavigation.dart';

class CreateLedger extends StatefulWidget {
  final String? rights;
  const CreateLedger({Key? key, this.rights}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<CreateLedger> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final entrydateController = TextEditingController();
  final dobController = TextEditingController();
  final dojController = TextEditingController();
  final domController = TextEditingController();
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _staffNameController = TextEditingController();

  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();
  final TextEditingController _receiptNoController = TextEditingController();
  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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

  Future<void> _createStaff() async {
    // Check if the form is valid
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Exit the method if validation fails
    }
    final String apiUrl = 'https://chits.tutytech.in/staff.php';

    try {
      // Print the request URL and body for debugging
      print('Request URL: $apiUrl');
      print(
        'Request body: ${{'type': 'insert', 'staffId': _staffIdController.text, 'staffName': _staffNameController.text, 'address': _addressController.text, 'mobileNo': _mobileNoController.text, 'userName': _userNameController.text, 'password': _passwordController.text, 'branch': selectedBranchName, 'branchCode': _branchCodeController.text, 'receiptNo': _receiptNoController.text, 'rights': selectedRights, 'companyid': _companyIdController.text, 'email': _emailController.text}}',
      );

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'type': 'insert',
          'staffId': _staffIdController.text,
          'staffName': _staffNameController.text,
          'address': _addressController.text,
          'mobileNo': _mobileNoController.text,
          'userName': _userNameController.text,
          'password': _passwordController.text,
          'branch': selectedBranchName,
          'branchCode': _branchCodeController.text,
          'receiptNo': _receiptNoController.text,
          'rights': selectedRights,
          'companyid': _companyIdController.text,
          'email': _emailController.text,
        },
      );

      // Print the response body for debugging
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if responseData contains staffId
        if (responseData is List && responseData.isNotEmpty) {
          _staffId =
              responseData[0]['id']; // Assuming 'id' is the field for staffId
          if (_staffId != null) {
            print('Extracted staffId: $_staffId'); // Debugging
            _showSnackBar('Staff created successfully! ID: $_staffId');
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         CreateCustomer(staffId: staffId), // Pass staffId
            //   ),
            // );
          } else {
            _showSnackBar('Error: Staff ID is null.');
          }
        } else {
          _showSnackBar('Error: Invalid response format.');
        }
      } else {
        _showSnackBar(
          'Failed to create staff. Status code: ${response.statusCode}',
        );
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
        title: 'Create Ledger',
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
                        controller: _customerNameController,
                        label: 'Enter Customer Name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Customer name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _mobileController,
                        label: 'MobileNo',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mobile number is required';
                          }
                          if (value.length < 10) {
                            return 'Enter a valid mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _gstinController,
                        label: 'GSTIN',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'GSTIN is required';
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
                                    // Save action
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
                                onPressed: () {},
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
        width: 60, // Ensures the button is a perfect circle
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          shape: const CircleBorder(), // Ensures circular shape
          onPressed: () {},
          child: const Icon(
            Icons.create_new_folder,
            size: 30,
            color: Colors.white,
          ),
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
