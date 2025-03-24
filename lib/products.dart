import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orderapp/customersearchform.dart';
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
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   fetchBranches(); // Fetch branches when the widget dependencies change
  // }

  Future<void> _createProduts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final String? companyId = prefs.getString('companyId');
    // Check if the form is valid

    final String apiUrl = 'https://varav.tutytech.in/product.php';

    try {
      // Print the request URL and body for debugging
      print('Request URL: $apiUrl');
      print(
        'Request body: ${{'type': 'insert', 'productcode': productCodeController.text, 'productname': productNameController.text, 'purchaseunit': selectedPurchaseUnit, 'qty': qtyController.text, 'salesunit': selectedSalesUnit, 'kg': noOfKgsController.text, 'salesrate': salesRateController.text, 'wholesalerate': wholeSaleRateController.text, 'purchaserate': purchaseRateController.text, 'mrp': mrpController.text, 'gst': gstController.text, 'gsttype': selectedGstType}}',
      );

      final response = await http.post(
        Uri.parse(apiUrl),

        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'type': 'insert',
          'productcode': productCodeController.text,
          'productname': productNameController.text,
          'purchaseunit': selectedPurchaseUnit,
          'purchaseqty': qtyController.text,
          'salesunit': selectedSalesUnit,
          'salesqty': noOfKgsController.text,
          'salesrate': salesRateController.text,
          'wholesalerate': wholeSaleRateController.text,
          'purchaserate': purchaseRateController.text,
          'mrp': mrpController.text,
          'gst': gstController.text,
          'gsttype': selectedGstType,
          'entryid': userId,
          'companyid': companyId,
        },
      );

      // Print the response body for debugging
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if responseData contains staffId
      } else {
        _showSnackBar(
          'Failed to create ledger. Status code: ${response.statusCode}',
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
                        controller: productCodeController,
                        decoration: const InputDecoration(
                          labelText: "Product Code",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Product Name
                      TextFormField(
                        controller: productNameController,
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
                              value: selectedPurchaseUnit,
                              items:
                                  ["Unit 1", "Unit 2", "Unit 3"]
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
                                  ["Unit 1", "Unit 2", "Unit 3"]
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
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: noOfKgsController,
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
                        controller: salesRateController,
                        decoration: const InputDecoration(
                          labelText: "Sales Rate",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: wholeSaleRateController,
                        decoration: const InputDecoration(
                          labelText: "WholeSale Rate",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: purchaseRateController,
                        decoration: const InputDecoration(
                          labelText: "Purchase Rate",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: mrpController,
                        decoration: const InputDecoration(
                          labelText: "MRP",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: gstController,
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
                                    _createProduts();
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
}
