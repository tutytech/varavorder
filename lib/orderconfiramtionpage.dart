import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderConfirmation extends StatefulWidget {
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

  const OrderConfirmation({
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

class _OrderPageState extends State<OrderConfirmation> {
Future<void> _createOrderConfirm() async {
  print('Order Confirm API: Started');
  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('userId');

  final String apiUrl = 'https://varav.tutytech.in/orderconfirm.php';

  try {
    print('Order Confirm API: Sending request to $apiUrl');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'type': 'insert',
        'total': widget.billAmount.toString(),
        'cgst': widget.totalcgst.toString(),
        'sgst': widget.totalsgst.toString(),
        'igst': widget.totaligst.toString(),
        'billamount': widget.totalamount.toString(),
        'cusid': widget.id,
        'entryid': userId ?? '',
      },
    );

    print('Order Confirm API Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body.trim());

      String? orderId;

      if (responseData is List && responseData.isNotEmpty && responseData[0]['id'] != null) {
        orderId = responseData[0]['id'].toString();
      } else if (responseData is Map<String, dynamic> && responseData.containsKey('id')) {
        orderId = responseData['id'].toString();
      }

      if (orderId != null) {
        print('Order Confirmed! Order ID: $orderId');
        await _createOrderDetails(orderId); // Proceed with order details API
      } else {
        _showSnackBar('Order ID not found in response.');
      }
    } else {
      _showSnackBar('Failed to create order. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
    _showSnackBar('An error occurred: $e');
  }
}


  Future<void> _createOrderDetails(String orderId) async {
    print('Order Details API: Started');
    final String apiUrl = 'https://varav.tutytech.in/orderdet.php';

    if (widget.products.isEmpty) {
      print('No products found');
      _showSnackBar('No products found');
      return;
    }

    try {
      // Loop through each product and send its details
     for (var product in widget.products) {
  var productId = product['id'];
  var qty = product['qty'];
  var rate = product['total'];

  print('Sending Order Details for Product ID: $productId');

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'type': 'insert',
      'productid': productId.toString(),
      'orderid': orderId,
      'rate': rate.toString(),
      'gst': widget.totalgst.toString(), // or product['gst']
      'qty': qty.toString(),
    },
  );

  final responseData = json.decode(response.body);
  print('Order Details API Response for Product $productId: ${response.body}');

  if (response.statusCode != 200 || responseData['success'] != true) {
    _showSnackBar('Failed to insert order details for product $productId');
  }
}

    } catch (e) {
      print('Error inserting order details: $e');
      _showSnackBar('An error occurred while inserting order details: $e');
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
              const Text(
                "Products Selected:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children:
                    widget.products.map((product) {
                      return _buildProductItem(
                        product['name'],
                        product['qty'],
                        product['total'],
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
              _buildBillDetail("Subtotal", widget.billAmount),
              _buildBillDetail("GST", widget.totalgst),
              _buildBillDetail(
                "Total Amount",
                widget.totalamount,
                isTotal: true,
              ),

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
                      _createOrderConfirm();
                    },
                    child: const Text(
                      "Confirm Order",
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
