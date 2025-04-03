import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:orderapp/createledger.dart';
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/orderpage.dart';
import 'package:orderapp/widgets/customnavigation.dart';

class Orderlistview extends StatefulWidget {
  final String? name, id;
  final String? phoneNo;
  final String? address;
  final List<Map<String, dynamic>>? customers;

  Orderlistview({
    Key? key,
    this.customers,
    this.id,
    this.name,
    this.phoneNo,
    this.address,
  }) : super(key: key);

  @override
  _BranchListPageState createState() => _BranchListPageState();
}

class _BranchListPageState extends State<Orderlistview> {
  late Future<List<Map<String, dynamic>>> _branchListFuture;
  List<Map<String, dynamic>> _allBranches = [];
  List<Map<String, dynamic>> _filteredBranches = [];
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> branchNames = [];
  String? _staffId;

  @override
  void initState() {
    super.initState();
    _branchListFuture = fetchTotalOrders();
    _searchController.addListener(() {
      _filterBranches(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> cancelOrder(int orderId) async {
    final url = Uri.parse('https://varav.tutytech.in/orderconfirm.php');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'type': 'cancel', 'orderId': orderId.toString()},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTotalOrders() async {
    String apiUrl = 'https://varav.tutytech.in/orderconfirm.php'; // API URL

    try {
      final Map<String, String> requestBody = {'type': 'select'};

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Print response body

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        if (decodedResponse.containsKey('data')) {
          return List<Map<String, dynamic>>.from(decodedResponse['data']);
        } else {
          throw Exception('Data list not found in response');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void _filterBranches(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = _allBranches;
      } else {
        _filteredBranches =
            _allBranches
                .where(
                  (branch) => branch['name'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      body: Stack(
        children: [
          Container(
            color: Colors.white, // Use 'color' instead of 'colors'
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2), // Shadow position
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Orders',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ), // Set label text color to white
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                      ), // Ensures the input text is also white
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Fetched data container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2), // Shadow position
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _branchListFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No branches found'));
                        }

                        _allBranches = snapshot.data!;
                        _filteredBranches =
                            _searchController.text.isEmpty
                                ? _allBranches
                                : _filteredBranches;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width,
                            ),
                            child: DataTable(
                              headingRowColor: MaterialStateColor.resolveWith(
                                (states) =>
                                    Colors.red, // Light background for headers
                              ),
                              columns: [
                                DataColumn(
                                  label: Text(
                                    'ID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          Colors
                                              .white, // Blue color to match gradient theme
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Order Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          Colors
                                              .white, // Blue color to match gradient theme
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'CusId',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'CGST',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                DataColumn(
                                  label: Text(
                                    'SGST',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'IGST',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'BillAmount',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Actions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                              rows:
                                  _filteredBranches.map((branch) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(branch['id'] ?? 'N/A')),
                                        DataCell(
                                          Text(branch['orderdate'] ?? '0'),
                                        ),
                                        DataCell(
                                          Text(branch['cusid'] ?? 'N/A'),
                                        ),
                                        DataCell(
                                          Text(branch['total'] ?? 'N/A'),
                                        ),
                                        DataCell(Text(branch['cgst'] ?? 'N/A')),
                                        DataCell(Text(branch['sgst'] ?? 'N/A')),
                                        DataCell(Text(branch['igst'] ?? 'N/A')),
                                        DataCell(
                                          Text(branch['billamount'] ?? 'N/A'),
                                        ),

                                        DataCell(
                                          ElevatedButton(
                                            onPressed: () async {
                                              int orderId =
                                                  int.tryParse(
                                                    branch['id'].toString(),
                                                  ) ??
                                                  0;
                                              if (orderId != 0) {
                                                bool success =
                                                    await cancelOrder(orderId);
                                                if (success) {
                                                  print(
                                                    'Order $orderId canceled successfully',
                                                  );
                                                } else {
                                                  print(
                                                    'Failed to cancel order $orderId',
                                                  );
                                                }
                                              } else {
                                                print('Invalid Order ID');
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors
                                                      .red, // ✅ Red background
                                              foregroundColor:
                                                  Colors.white, // ✅ White text
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ), // ✅ Padding
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      8,
                                                    ), // ✅ Rounded corners
                                              ),
                                            ),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ), // ✅ Bold text
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                ],
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
}
