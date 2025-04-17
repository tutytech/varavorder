import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orderapp/orderlist.dart';
import 'package:orderapp/orderlistview.dart';
import 'package:orderapp/orderpage.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerSearchPage extends StatefulWidget {
  final String? name, id;
  final String? phoneNo;
  final String? address;
  final List<Map<String, dynamic>>? customers;
  CustomerSearchPage({
    Key? key,
    this.customers,
    this.id,
    this.name,
    this.phoneNo,
    this.address,
  }) : super(key: key);

  @override
  _CustomerSearchPageState createState() => _CustomerSearchPageState();
}

class _CustomerSearchPageState extends State<CustomerSearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  Map<String, dynamic>? selectedCustomer;

  @override
  void initState() {
    super.initState();
    fetchLedgers();
  }

  Future<void> fetchLedgers() async {
    const String _baseUrl = 'https://varav.tutytech.in/ledgerform.php';

    // Retrieve companyId from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? companyId = prefs.getString('companyid');

    if (companyId == null) {
      print('Error: companyId is not available in SharedPreferences');
      return;
    }

    final Map<String, String> requestBody = {
      'type': 'select',
      'companyid': companyId, // ✅ Correct key format with capital "I"
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      print('Request URL: $_baseUrl');
      print('Request Body: $requestBody');
      print('Response Status Code: ${response.statusCode}');
      print('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey('data') &&
            decodedResponse['data'] is List) {
          final List<dynamic> data = decodedResponse['data'];

          setState(() {
            customers = List<Map<String, dynamic>>.from(data);
            filteredCustomers = customers;
          });
        } else {
          print('Decoded response: $decodedResponse');
          throw Exception(
            'Unexpected response format: ${decodedResponse.runtimeType}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers =
            customers
                .where(
                  (customer) =>
                      (customer['customername'] ?? '').toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      (customer['mobileno'] ?? '').contains(query) ||
                      (customer['gstin'] ?? '').toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  void navigateToOrderPage(
    String name,
    String phoneNo,
    String address,
    String id,
    Map<String, dynamic> customer,
  ) {
    print("Navigating with ID: $id"); // Optional print
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderPage(
              name: name,
              phoneNo: phoneNo,
              address: address,
              id: id,
              customers: [customer],
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Search Customer", style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  // ✅ Makes TextField take full width
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: filterSearch,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    // await fetchLedgers(); // ✅ Fetch customer details before navigating

                    if (filteredCustomers.isNotEmpty) {
                      // ✅ Extract individual properties into separate lists
                      List<String> names =
                          filteredCustomers
                              .map((c) => (c['customername'] ?? '').toString())
                              .toList();
                      List<String> phoneNos =
                          filteredCustomers
                              .map((c) => (c['mobileno'] ?? '').toString())
                              .toList();
                      List<String> addresses =
                          filteredCustomers
                              .map((c) => (c['address'] ?? '').toString())
                              .toList();
                      List<String> ids =
                          filteredCustomers
                              .map((c) => (c['id'] ?? '').toString())
                              .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Orderlistview(
                                name: names.toString(),
                                phoneNo: phoneNos.toString(),
                                address: addresses.toString(),
                                id: ids.toString(),
                              ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No customer data available'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View List'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Expanded(
              child:
                  filteredCustomers.isEmpty
                      ? const Center(
                        child: Text(
                          "No customers found",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return ListTile(
                            title: Text(customer['customername'] ?? 'Unknown'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Phone: ${customer['mobileno'] ?? 'N/A'}"),
                                Text(
                                  "GSTIN: ${customer['gstin'] ?? 'N/A'}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedCustomer =
                                      customer; // Store selected customer
                                });
                                navigateToOrderPage(
                                  customer['customername'] ?? '',
                                  customer['mobileno'] ?? '',
                                  customer['address'] ?? '',
                                  (customer['id'] ?? '')
                                      .toString(), // Convert to string here
                                  customer,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                "Select",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
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

// Widget productItem(String name, String quantity, String price) {
//   return Container(
//     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: Colors.grey.shade300),
//     ),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               name,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const Text("Regular", style: TextStyle(color: Colors.grey)),
//             const Text("Customize", style: TextStyle(color: Colors.red)),
//           ],
//         ),
//         Row(
//           children: [
//             // Minus Button
//             IconButton(
//               onPressed: () {
//                 // Ensure quantity doesn't go below 1
//                 int currentQuantity = int.parse(quantity);
//                 if (currentQuantity > 1) {
//                   setState(() {
//                     quantity = (currentQuantity - 1).toString();
//                   });
//                 }
//               },
//               icon: const Icon(Icons.remove, color: Colors.red),
//             ),

//             // Quantity Box
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.red),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 quantity,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             // Plus Button
//             IconButton(
//               onPressed: () {
//                 int currentQuantity = int.parse(quantity);
//                 setState(() {
//                   quantity = (currentQuantity + 1).toString();
//                 });
//               },
//               icon: const Icon(Icons.add, color: Colors.red),
//             ),

//             const SizedBox(width: 10),

//             // Price Display
//             Text(price, style: const TextStyle(fontSize: 16)),
//           ],
//         ),
//       ],
//     ),
//   );
// }

Widget billDetailRow(String title, String amount, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
