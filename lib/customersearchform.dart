import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orderapp/orderpage.dart';
import 'package:orderapp/widgets/customnavigation.dart';

class CustomerSearchPage extends StatefulWidget {
  @override
  _CustomerSearchPageState createState() => _CustomerSearchPageState();
}

class _CustomerSearchPageState extends State<CustomerSearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    fetchLedgers();
  }

  Future<void> fetchLedgers() async {
    const String _baseUrl = 'https://varav.tutytech.in/ledgerform.php';
    final Map<String, String> requestBody = {'type': 'select'};

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse is List) {
          setState(() {
            customers = List<Map<String, dynamic>>.from(decodedResponse);
            filteredCustomers = customers;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch data');
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
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderPage(
              name: name,
              phoneNo: phoneNo,
              address: address,
              id: id,
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
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Name, Phone No, or GSTIN',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.black),
              ),
              onChanged: filterSearch,
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
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                navigateToOrderPage(
                                  customer['customername'] ?? '',
                                  customer['mobileno'] ?? '',
                                  customer['address'] ?? '',
                                  customer['id'] ?? '',
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
