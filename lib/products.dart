import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/productlist.dart';
import 'dart:convert';

import 'package:orderapp/widgets/customappbar.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController productCodeController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController groupController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController noOfKgsController = TextEditingController();
  final TextEditingController salesRateController = TextEditingController();
  final TextEditingController wholeSaleRateController = TextEditingController();
  final TextEditingController purchaseRateController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  String? selectedGstType;
  String? selectedRights;
  String? selectedPurchaseUnit;
  String? selectedSalesUnit;
  String? selectedGroup;
  List<String> groupNames = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchGroupsFromApi(); // Fetch branches when the widget dependencies change
  }

  Future<List<String>> fetchGroups() async {
    const String _baseUrl = 'https://varav.tutytech.in/group.php';

    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyid');

    // Ensure the companyId is not null or empty
    if (companyId == null || companyId.isEmpty) {
      throw Exception("Company ID is missing.");
    }

    final Map<String, String> requestBody = {
      'type': 'select',
      'companyid': companyId, // Add companyid here
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey('data')) {
          final data = decodedResponse['data'];
          if (data is List) {
            // Assuming each item in 'data' contains a 'groupname' field
            return List<String>.from(
              data.map((item) => item['groupname'] ?? ''),
            );
          } else {
            throw Exception('Expected "data" to be a List');
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch groups (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Fetch groups and update the state
  Future<void> fetchGroupsFromApi() async {
    try {
      List<String> groups = await fetchGroups();
      setState(() {
        groupNames = groups; // Save the group names to the list
      });
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  Future<void> _createProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId') ?? "";
    final String? companyId = prefs.getString('companyid') ?? "";

    final String apiUrl = 'https://varav.tutytech.in/product.php';

    try {
      // Prepare request body and ensure all values are strings
      Map<String, String> requestBody = {
        'type': 'insert',
        'productcode':
            productCodeController.text.isNotEmpty
                ? productCodeController.text
                : "N/A",
        'productname':
            productNameController.text.isNotEmpty
                ? productNameController.text
                : "N/A",
        'group': selectedGroup ?? "N/A",
        'purchaseunit': selectedPurchaseUnit ?? "N/A",
        'purchaseqty': qtyController.text.isNotEmpty ? qtyController.text : "0",
        'salesunit': selectedSalesUnit ?? "N/A",
        'salesqty':
            noOfKgsController.text.isNotEmpty ? noOfKgsController.text : "0",
        'salesrate':
            salesRateController.text.isNotEmpty
                ? salesRateController.text
                : "0",
        'wholesalerate':
            wholeSaleRateController.text.isNotEmpty
                ? wholeSaleRateController.text
                : "0",
        'purchaserate':
            purchaseRateController.text.isNotEmpty
                ? purchaseRateController.text
                : "0",
        'mrp': mrpController.text.isNotEmpty ? mrpController.text : "0",
        'gst': gstController.text.isNotEmpty ? gstController.text : "0",
        'gsttype': selectedGstType ?? "INCLUDE GST",
        'entryid': userId.toString(),
        'companyid': companyId.toString(),
      };

      // Debugging: Print request body
      print('Request URL: $apiUrl');
      print('Request body: $requestBody');

      // Send request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      // Debugging: Print response
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData');

        // Show success message
        _showSnackBar('Product created successfully');

        // Wait briefly for the snackbar to show
        await Future.delayed(const Duration(seconds: 1));

        // Navigate to ProductList page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => productlist()),
        );
      }
    } catch (e) {
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
                        controller: productCodeController,
                        decoration: const InputDecoration(
                          labelText: "Product Code",
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter product code'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Product Name
                      TextFormField(
                        controller: productNameController,
                        decoration: const InputDecoration(
                          labelText: "Product Name",
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter product name'
                                    : null,
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
                              value: selectedPurchaseUnit,
                              items:
                                  ["Piece", "Dozen", "Box", "Bag"]
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedPurchaseUnit = value;
                                });
                              },
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Select purchase unit'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: qtyController,
                              decoration: const InputDecoration(
                                labelText: "Qty",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Enter quantity'
                                          : null,
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
                              value: selectedSalesUnit,
                              items:
                                  ["Piece", "Dozen", "Box", "Bag"]
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSalesUnit = value;
                                });
                              },
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Select sales unit'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: noOfKgsController,
                              decoration: const InputDecoration(
                                labelText: "No of KGS/LTRS",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Enter No of KGS'
                                          : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Group",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedGroup,
                        items:
                            groupNames
                                .map(
                                  (group) => DropdownMenuItem(
                                    value: group,
                                    child: Text(group),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGroup = value; // Update selected group
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Select product group' : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: salesRateController,
                        decoration: const InputDecoration(
                          labelText: "Sales Rate",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter sales rate'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: wholeSaleRateController,
                        decoration: const InputDecoration(
                          labelText: "WholeSale Rate",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter wholesale rate'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: purchaseRateController,
                        decoration: const InputDecoration(
                          labelText: "Purchase Rate",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter purchase rate'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: mrpController,
                        decoration: const InputDecoration(
                          labelText: "MRP",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter MRP'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: gstController,
                        decoration: const InputDecoration(
                          labelText: "GST %",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter GST %'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "GST Type",
                          border: OutlineInputBorder(),
                        ),
                        value: selectedGstType,
                        items:
                            ["INCLUDE GST", "EXCLUDE GST"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGstType = value;
                          });
                        },
                        validator:
                            (value) => value == null ? 'Select GST type' : null,
                      ),
                      const SizedBox(height: 16),

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
                                    _createProducts();
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
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => productlist(),
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
}
