import 'package:flutter/material.dart';
import 'package:orderapp/orderpage.dart';
import 'package:orderapp/widgets/customnavigation.dart';

class CustomerSearchPage extends StatefulWidget {
  @override
  _CustomerSearchPageState createState() => _CustomerSearchPageState();
}

class _CustomerSearchPageState extends State<CustomerSearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> customers = [
    {"customerName": "John Doe", "phoneNo": "9876543210", "gst": "GST001"},
    {"customerName": "Jane Smith", "phoneNo": "9988776655", "gst": "GST002"},
    {"customerName": "Mike Johnson", "phoneNo": "9123456789", "gst": "GST003"},
  ];
  List<Map<String, String>> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    filteredCustomers = []; // Initially, do not show any customers
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = [];
      } else {
        filteredCustomers =
            customers
                .where(
                  (customer) =>
                      customer["customerName"]!.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      customer["phoneNo"]!.contains(query) ||
                      customer["gst"]!.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  void navigateToOrderPage(String name, String phoneNo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(name: name, phoneNo: phoneNo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            "Search Customer",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by Name, Phone No, or GST',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                  ),
                  onChanged: filterSearch,
                ),
              ),
              const SizedBox(height: 20),
              filteredCustomers.isEmpty
                  ? const Center(
                    child: Text(
                      "Search for a customer",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap:
                        true, // Important to avoid infinite height issue
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return ListTile(
                        title: Text(customer["customerName"]!),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Phone: ${customer["phoneNo"]}"),
                            Text(
                              "GST: ${customer["gst"]}",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            navigateToOrderPage(
                              customer["customerName"]!,
                              customer["phoneNo"]!,
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

              const SizedBox(height: 20),

              // Product Details (Static)
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {},
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(onItemSelected: (int) {}),
    );
  }

  Widget productItem(String name, String quantity, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("Regular", style: TextStyle(color: Colors.grey)),
              const Text("Customize", style: TextStyle(color: Colors.red)),
            ],
          ),
          Row(
            children: [
              // Minus Button
              IconButton(
                onPressed: () {
                  // Ensure quantity doesn't go below 1
                  int currentQuantity = int.parse(quantity);
                  if (currentQuantity > 1) {
                    setState(() {
                      quantity = (currentQuantity - 1).toString();
                    });
                  }
                },
                icon: const Icon(Icons.remove, color: Colors.red),
              ),

              // Quantity Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  quantity,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Plus Button
              IconButton(
                onPressed: () {
                  int currentQuantity = int.parse(quantity);
                  setState(() {
                    quantity = (currentQuantity + 1).toString();
                  });
                },
                icon: const Icon(Icons.add, color: Colors.red),
              ),

              const SizedBox(width: 10),

              // Price Display
              Text(price, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

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
}
