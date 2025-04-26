import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:orderapp/createledger.dart';
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/orderpage.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class Orderreportview extends StatefulWidget {
  final String? name, fromDate, toDate;
  final int? id;

  final String? address;
  final List<Map<String, dynamic>>? customers;
  List<dynamic>? orders = [];

  Orderreportview({
    Key? key,
    this.customers,
    this.fromDate,
    this.toDate,
    this.id,
    this.name,
    this.orders,
    this.address,
  }) : super(key: key);

  @override
  _BranchListPageState createState() => _BranchListPageState();
}

class _BranchListPageState extends State<Orderreportview> {
  Future<List<Map<String, dynamic>>>? _branchListFuture;

  List<Map<String, dynamic>> _allBranches = [];
  List<Map<String, dynamic>> _filteredBranches = [];
  final GlobalKey<NavigatorState> globalNavigatorKey =
      GlobalKey<NavigatorState>();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  List<String> branchNames = [];
  String? _staffId;
  String? customerName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _searchController.addListener(() {
      _filterBranches(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  Future<bool> cancelOrder(int orderId) async {
    final url = Uri.parse('https://varav.tutytech.in/orderconfirm.php');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'type': 'cancel', 'orderId': orderId},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrdersByDate(
    BuildContext context,
  ) async {
    String fromDate = fromDateController.text;
    String toDate = toDateController.text;
    print("Fetching orders from $fromDate to $toDate");

    var url = Uri.parse('https://varav.tutytech.in/orderconfirm.php');

    try {
      var response = await http.post(
        url,
        body: {
          "type": "select_by_date",
          "fromDate": fromDate,
          "toDate": toDate,
        },
      );

      print("API Request Sent");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print("Parsed Response Data: $responseData");

        if (responseData['error'] == null && responseData['success'] == true) {
          print("Data received successfully!");

          if (responseData['data'] == null) {
            return [];
          }

          List<Map<String, dynamic>> orders = List<Map<String, dynamic>>.from(
            responseData['data'],
          );

          // Optional: Print customer names
          for (var order in orders) {
            customerName = order['customername'] ?? 'Unknown';
            print("Customer Name: $customerName");
          }

          return orders;
        } else {
          print("API Error: ${responseData['error']}");
        }
      } else {
        print("API Call Failed with Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception Caught: $e");
    }

    print("Returning empty list due to failure");
    return [];
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

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (status.isGranted) return true;

      status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> _downloadExcelReport(List<Map<String, dynamic>> branches) async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print('❌ Storage permission denied');
        return;
      }

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Report'];

      // Add header row
      sheetObject.appendRow([
        TextCellValue('ID'),
        TextCellValue('Order No'),
        TextCellValue('Order Date'),
        TextCellValue('Customer Name'),
        TextCellValue('Bill Amount'),
      ]);

      // Add data rows
      for (var branch in branches) {
        sheetObject.appendRow([
          TextCellValue(branch['id']?.toString() ?? ''),
          TextCellValue(branch['orderno']?.toString() ?? ''),
          TextCellValue(branch['orderdate']?.toString() ?? ''),
          TextCellValue(branch['customername']?.toString() ?? ''),
          TextCellValue(branch['billamount']?.toString() ?? ''),
        ]);
      }

      var bytes = excel.encode();
      if (bytes == null) {
        print('❌ Excel encoding failed');
        return;
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String dirPath = directory!.path;
      String filePath =
          '$dirPath/Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      File file = File(filePath);

      await file.writeAsBytes(bytes);

      print('✅ Report downloaded at: $filePath');
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Report downloaded: ${file.path}')),
      );
    } catch (e) {
      print('❌ Error downloading Excel report: $e');
    }
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
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From Date
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.only(
                            right: 8,
                          ), // spacing between fields
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
                                    () => _selectDate(
                                      context,
                                      fromDateController,
                                    ),
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
                      ),

                      // To Date
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
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
                                    () =>
                                        _selectDate(context, toDateController),
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
                      ),

                      // Search Button
                      ElevatedButton(
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

                          setState(() {
                            _branchListFuture = fetchOrdersByDate(context);
                          });

                          print("From Date: ${fromDateController.text}");
                          print("To Date: ${toDateController.text}");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                              labelStyle: TextStyle(color: Colors.black),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                            ),
                            style: const TextStyle(
                              color:
                                  Colors.black, // Ensure input text is visible
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ), // Spacing between search bar and button
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_filteredBranches.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No data available to download'),
                              ),
                            );
                            return;
                          }

                          await _downloadExcelReport(_filteredBranches);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.download),
                        label: const Text("Download Report"),
                      ),
                    ],
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
                    child:
                        _branchListFuture == null
                            ? const SizedBox.shrink()
                            : FutureBuilder<List<Map<String, dynamic>>>(
                              future: _branchListFuture,
                              builder: (context, snapshot) {
                                print(
                                  "🔄 FutureBuilder called: ConnectionState = ${snapshot.connectionState}",
                                );

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  print("⏳ Loading data...");
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  print(
                                    "❌ FutureBuilder Error: ${snapshot.error}",
                                  );
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  print("⚠️ No branches found.");
                                  return const Center(
                                    child: Text(
                                      'No data found for the selected dates',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }

                                print(
                                  "✅ Data received in FutureBuilder: ${snapshot.data}",
                                );

                                _allBranches = snapshot.data!;
                                _filteredBranches =
                                    _searchController.text.isEmpty
                                        ? _allBranches
                                        : _allBranches.where((branch) {
                                          final query =
                                              _searchController.text
                                                  .toLowerCase();
                                          return branch['customername']
                                                  ?.toString()
                                                  .toLowerCase()
                                                  .contains(query) ??
                                              false;
                                        }).toList();

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                    ),
                                    child: DataTable(
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                            (states) => Colors.red,
                                          ),
                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'ID',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Order No',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Order Date',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Customer Name',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Bill Amount',
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
                                            print(
                                              "📝 Processing Branch: $branch",
                                            );
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    branch['id']?.toString() ??
                                                        'N/A',
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    (branch['orderno'] ?? 'N/A')
                                                        .toString(),
                                                  ),
                                                ),

                                                DataCell(
                                                  Text(
                                                    branch['orderdate'] ??
                                                        'N/A',
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    branch['customername'] ??
                                                        'N/A',
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    branch['billamount']
                                                            ?.toString() ??
                                                        'N/A',
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
