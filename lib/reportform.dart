import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:orderapp/widgets/customappbar.dart';
import 'package:orderapp/widgets/customnavigation.dart';

class Report extends StatefulWidget {
  final String? rights;
  const Report({Key? key, this.rights}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<Report> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
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
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

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
        title: 'Report',
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
                  padding: const EdgeInsets.only(top: 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      // From Date
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.2,
                              ), // Shadow color
                              blurRadius: 5, // Blur intensity
                              spreadRadius: 2, // Spread
                              offset: const Offset(0, 3), // Shadow position
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: fromDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'From Date',
                            labelStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                              ),
                              onPressed:
                                  () =>
                                      _selectDate(context, fromDateController),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'From Date is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // To Date
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: toDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'To Date',
                            labelStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                              ),
                              onPressed:
                                  () => _selectDate(context, toDateController),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'To Date is required';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (fromDateController.text.isEmpty ||
                                toDateController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select both dates'),
                                ),
                              );
                              return;
                            }

                            // Handle Save Logic Here
                            print("From Date: ${fromDateController.text}");
                            print("To Date: ${toDateController.text}");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Red background
                            foregroundColor: Colors.white, // White text color
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ), // Adjust padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Rounded corners
                            ),
                          ),
                          child: const Text(
                            'Export To Excel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
          child: const Icon(Icons.shopping_cart, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(onItemSelected: (int) {}),
    );
  }

  // Custom TextField with Box Shadow
}
