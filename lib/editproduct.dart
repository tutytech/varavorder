import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/productlist.dart';
import 'dart:convert';

import 'package:orderapp/widgets/customappbar.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Editproducts extends StatefulWidget {
  final String? rights, id;
  const Editproducts({Key? key, this.rights, this.id}) : super(key: key);

  @override
  _CreateBranchState createState() => _CreateBranchState();
}

class _CreateBranchState extends State<Editproducts> {
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
  String? selectedGroup;
  String? selectedSalesUnit;
  List<Map<String, dynamic>> product = [];
  bool isLoading = true;
  bool? isActive;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.id != null) {
      fetchproducts(widget.id!);
    } else {
      _showError('Invalid branch ID provided.');
    } // Fetch branches when the widget dependencies change
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> fetchproducts(String id) async {
    print('Fetching products...');
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyid');

    // Ensure the companyId is not null or empty
    if (companyId == null || companyId.isEmpty) {
      throw Exception("Company ID is missing.");
    }
    const String _baseUrl = 'https://varav.tutytech.in/product.php';

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
          product =
              dataList
                  .map<Map<String, dynamic>>(
                    (scheme) => {
                      'id': scheme['id'].toString(),
                      // 'name': scheme['scheme'].toString(),
                    },
                  )
                  .toSet()
                  .toList();

          print('Ledgers: $product');

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
        _showError('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showError('An error occurred while fetching products.');
    }
  }

  void _updateBranchFields(Map<String, dynamic> branch) {
    print('Updating fields with branch data: $branch');
    productCodeController.text = branch['productcode'].toString() ?? '';
    productNameController.text = branch['productname'] ?? '';
    selectedPurchaseUnit = branch['purchaseunit']?.toString() ?? '';
    qtyController.text = branch['purchaseqty'] ?? '';
    selectedSalesUnit = branch['salesunit'] ?? '';
    noOfKgsController.text = branch['salesqty'] ?? '';
    selectedGroup = branch['group'] ?? '';
    salesRateController.text = branch['salesrate'] ?? '';
    wholeSaleRateController.text = branch['wholesalerate'] ?? '';
    purchaseRateController.text = branch['purchaserate'] ?? '';
    mrpController.text = branch['mrp'] ?? '';
    gstController.text = branch['gst'] ?? '';
    selectedGstType = branch['gsttype'] ?? '';
  }

  Future<void> _updateProducts() async {
    final String activeStatus = isActive == true ? 'Y' : 'N';
    print('---------------${widget.id}');
    try {
      final url = Uri.parse('https://varav.tutytech.in/product.php');

      final requestBody = {
        'type': 'update',
        'id': widget.id.toString(),
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
            const SnackBar(content: Text('Products updated successfully!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => productlist()),
          );
          // Return to the previous screen
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
        title: 'Edit Products',
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
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Group",
                          border: OutlineInputBorder(),
                        ),
                        value:
                            [
                                  "Oil",
                                  "Soap",
                                  "Rice",
                                  "Sugar",
                                  "Snacks",
                                ].contains(selectedGroup)
                                ? selectedGroup
                                : null,
                        items:
                            ["Oil", "Soap", "Rice", "Sugar", "Snacks"]
                                .map(
                                  (group) => DropdownMenuItem(
                                    value: group,
                                    child: Text(group),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGroup = value;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Select product group' : null,
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
                                  _updateProducts();
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
