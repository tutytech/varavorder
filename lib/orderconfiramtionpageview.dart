import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/orderlist.dart';
import 'package:orderapp/orderlistview.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderConfirmationview extends StatefulWidget {
  final String name, id;
  final String phoneNo;
  final String address;
  final List<Map<String, dynamic>> products;
  final double price;
  final int qty;
  final double total;
  final double billAmount,
      totalgst,
      totalamount,
      totalcgst,
      totalsgst,
      totaligst;
  final double gstRate;

  const OrderConfirmationview({
    Key? key,
    required this.id,
    required this.name,
    required this.phoneNo,
    required this.address,
    required this.products,
    required this.price,
    required this.qty,
    required this.total,
    required this.billAmount,
    required this.gstRate,
    required this.totalgst,
    required this.totalamount,
    required this.totalcgst,
    required this.totalsgst,
    required this.totaligst,
  }) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderConfirmationview> {
  double? gst;
  double? rate;
  double? productname;
  double totalGst = 0.0;
  double total = 0.0;
  double billAmount = 0.0;
  List<Map<String, dynamic>> orderDetails = [];
  @override
  void initState() {
    super.initState();
    fetchOrderDetails(widget.id);
  }

  Future<void> fetchOrderDetails(String orderId) async {
    print('Fetching order details for Order ID: $orderId');

    final response = await http.post(
      Uri.parse('https://varav.tutytech.in/orderdet.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'type': 'fetch', 'orderid': orderId},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Decoded JSON: $data');

      // Extract product details
      if (data['products'] != null && data['products'] is List) {
        orderDetails.clear();
        for (var product in data['products']) {
          totalGst = double.tryParse(product['gst'].toString()) ?? 0.0;
          orderDetails.add({
            'productname': product['productname'],
            'rate': double.tryParse(product['rate'].toString()) ?? 0.0,
            'gst': double.tryParse(product['gst'].toString()) ?? 0.0,
            'qty': int.tryParse(product['qty'].toString()) ?? 0,
          });
        }
        print('Parsed Order Details: $orderDetails');
      } else {
        print('No products found in response.');
      }

      // Extract total and billamount only
      final summary = data['summary'];
      if (summary != null && summary is Map<String, dynamic>) {
        setState(() {
          total = double.tryParse(summary['total'].toString()) ?? 0.0;
          billAmount = double.tryParse(summary['billamount'].toString()) ?? 0.0;
        });

        print('Summary Details:');
        print('Total: $total');
        print('Bill Amount: $billAmount');
      } else {
        print('No summary data found.');
      }
    } else {
      print(
        'Failed to fetch order details. Status code: ${response.statusCode}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back arrow
        title: Center(
          child: Text(
            "${widget.name} - ${widget.phoneNo}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Order Confirmation",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Customer Details
              Text(
                "Customer Name: ${widget.name}",
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                "Phone No: ${widget.phoneNo}",
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                "Address: ${widget.address}",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Product Details
              Text(
                "Products Selected:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Show order details
              Column(
                children:
                    orderDetails.map((product) {
                      return _buildProductItem(
                        product['productname'], // instead of product['name']
                        product['qty'],
                        (product['rate'] *
                            product['qty']), // calculate total if not already available
                      );
                    }).toList(),
              ),

              const Divider(thickness: 1, height: 30),

              // Bill Details
              const Text(
                "Bill Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _buildBillDetail("Subtotal", total),
              _buildBillDetail("GST", totalGst),
              _buildBillDetail("Total Amount", billAmount, isTotal: true),

              const SizedBox(height: 30),

              // Confirm Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Orderlist()),
                      );
                    },
                    child: const Text(
                      "Close",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildProductItem(String name, int qty, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Product Name × Quantity
          Text(
            "$name × $qty",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),

          // Price at the End
          Text(
            "Rs ${price.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetail(String title, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "\Rs.${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
