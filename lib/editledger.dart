import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orderapp/customersearchform.dart';
import 'dart:convert';

import 'package:orderapp/widgets/customappbar.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditLedger extends StatefulWidget {
  final String? rights, id;
  const EditLedger({Key? key, this.rights, this.id}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<EditLedger> {
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
  List<Map<String, dynamic>> ledger = [];
  bool isLoading = true;
  bool? isActive;
  String? selectedBranch;
  String? selectedRights;
  String? selectedBranchName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.id != null) {
      fetchledgers(widget.id!);
    } else {
      _showError('Invalid branch ID provided.');
    } // Fetch branches when the widget dependencies change
  }

  Future<void> fetchledgers(String id) async {
    print('Fetching ledgers...');
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyid');

    // Ensure the companyId is not null or empty
    if (companyId == null || companyId.isEmpty) {
      throw Exception("Company ID is missing.");
    }
    const String _baseUrl = 'https://varav.tutytech.in/ledgerform.php';

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
          ledger =
              dataList
                  .map<Map<String, dynamic>>(
                    (scheme) => {
                      'id': scheme['id'].toString(),
                      'name': scheme['scheme'].toString(),
                    },
                  )
                  .toSet()
                  .toList();

          print('Ledgers: $ledger');

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
        _showError('Failed to fetch ledgers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showError('An error occurred while fetching ledgers.');
    }
  }

  Future<void> _updateLedger() async {
    final String activeStatus = isActive == true ? 'Y' : 'N';
    print('---------------${widget.id}');
    try {
      final url = Uri.parse('https://varav.tutytech.in/ledgerform.php');

      final requestBody = {
        'type': 'update',
        'id': widget.id.toString(),

        'customername': _customerNameController.text.trim(),
        'address': _addressController.text.trim(),
        'mobileno': _mobileController.text.trim(),
        'gstin': _gstinController.text.trim(),
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
            const SnackBar(content: Text('Ledger updated successfully!')),
          );
          Navigator.pop(context, true); // Return to the previous screen
        } else {
          _showError(result[0]['message'] ?? 'Failed to update scheme.');
        }
      } else {
        _showError('Failed to update scheme: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error: $error');
      _showError('An error occurred: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _updateBranchFields(Map<String, dynamic> branch) {
    print('Updating fields with branch data: $branch');

    _customerNameController.text = branch['customername'] ?? '';
    _addressController.text = branch['address']?.toString() ?? '';
    _mobileController.text = branch['mobileno'] ?? '';
    _gstinController.text = branch['gstin'] ?? '';
  }

  Future<List<Map<String, dynamic>>> fetchBranches() async {
    const String apiUrl = 'https://varav.tutytech.in/branch.php';

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
        title: 'Edit Ledger',
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
                                    _updateLedger();
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomerSearchPage()),
            );
          },
          child: const Icon(Icons.shopping_cart, size: 30, color: Colors.white),
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
