import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:orderapp/widgets/customappbar.dart';
import 'package:orderapp/widgets/customnavigation.dart';

class products extends StatefulWidget {
  final String? rights;
  const products({Key? key, this.rights}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<products> {
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
        title: 'Create Products',
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
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Product Code
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Product Code",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Product Name
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Product Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Purchase Unit Dropdown
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Purchase Unit",
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  ["Unit 1", "Unit 2", "Unit 3"]
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Qty",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sales Unit & No of KGS (Side by Side)
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Sales Unit",
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  ["Unit 1", "Unit 2", "Unit 3"]
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: "No of KGS",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sales Rate
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Sales Rate",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // WholeSale Rate
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "WholeSale Rate",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Purchase Rate
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Purchase Rate",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // MRP
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "MRP",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // GST %
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "GST %",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // GST Type Dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "GST Type",
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ["INCLUDE GST", "EXCLUDE GST"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 16),

                      // Quantity Inputs
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
          child: const Icon(Icons.shopping_cart, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(onItemSelected: (int) {}),
    );
  }

  // Custom TextField with Box Shadow
}
