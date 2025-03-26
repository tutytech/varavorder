import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/orderconfiramtionpage.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget {
  final String name;
  final String phoneNo;

  const OrderPage({Key? key, required this.name, required this.phoneNo})
    : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  // Map to store product quantities
  final Map<String, int> _productQuantities = {
    "Creamy nachos": 1,
    "Maharaja mac": 1,
  };
  List<String> productNames = [];
  List<Map<String, dynamic>> productList = [];
  double gstPer = 5.0;
  int quantity = 0; // Default quantity starts from 0
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _controller.text = quantity.toString();
  }

  Future<void> fetchProducts() async {
    const String _baseUrl = 'https://varav.tutytech.in/product.php';
    final Map<String, String> requestBody = {'type': 'select'};

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is List && decodedResponse.isNotEmpty) {
          setState(() {
            productList =
                decodedResponse.map<Map<String, dynamic>>((product) {
                  return {
                    'name': product['productname'].toString(),
                    'price': "€${product['salesrate']}",
                    'purchaseprice': "€${product['purchaserate']}",
                    'mrp': "€${product['mrp']}",
                    'salesunit': "€${product['salesunit']}",
                    'qty':
                        int.tryParse(product['salesqty'].toString()) ??
                        0, // Ensure qty is an integer
                  };
                }).toList();
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
          'Failed to fetch products (HTTP ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void _updateQty(int newQty, {bool fromTextField = false}) {
    setState(() {
      quantity = newQty < 0 ? 0 : newQty; // Ensure qty doesn't go below 0
      if (!fromTextField) {
        _controller.text =
            quantity.toString(); // Update only when not from TextField
      }
    });
  }

  double getNumericPrice(String price) {
    return double.parse(price.replaceAll(RegExp(r'[^\d.]'), ''));
  }

  double calculateSRate(double price) {
    return (price * 100) / (100 + gstPer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back arrow
        title: Center(
          child: Text(
            "${widget.name} - ${widget.phoneNo}",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.red,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Order",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Product Items
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    productList.map((product) {
                      return productItem(
                        product['name'] as String,
                        product['price'] as String,
                        quantity, // Always send 0 initially
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),

              // Bill Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Bill Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const Divider(),
                    billDetailRow("Item Total", "€26.30"),
                    billDetailRow("Restaurant Charges", "€03.00"),
                    billDetailRow("Delivery Fee", "€01.00"),
                    billDetailRow("Offer 10% OFF", "- €03.03"),
                    const Divider(),
                    billDetailRow("To Pay", "€27.27", isBold: true),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Enter discount code",
                        suffixIcon: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            "APPLY",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OrderConfirmation(
                                  name: widget.name,
                                  phoneNo: widget.phoneNo,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "PROCEED",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
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

  Widget productItem(String name, String price, int qty) {
    double numericPrice = getNumericPrice(price);
    double totalPrice = numericPrice * qty;

    // Calculate 5% SGST, 5% CGST, 5% TGST
    double sgst = totalPrice * 0.05;
    double cgst = totalPrice * 0.05;
    double tgst = totalPrice * 0.05;

    // Total Tax (15% of total price)
    double totalTax = sgst + cgst + tgst;

    // Final amount after adding tax
    double finalAmount = totalPrice + totalTax;

    double calculatedSRate = qty > 0 ? calculateSRate(totalPrice) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
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
                onPressed: () => _updateQty(qty - 1),
                icon: const Icon(Icons.remove, color: Colors.red),
              ),

              // Quantity Input Box (Editable)
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    int? enteredQty = int.tryParse(value);
                    if (enteredQty != null) {
                      _updateQty(enteredQty);
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ),

              // Plus Button
              IconButton(
                onPressed: () => _updateQty(qty + 1),
                icon: const Icon(Icons.add, color: Colors.red),
              ),

              const SizedBox(width: 10),

              // Price & Tax Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Rs ${calculatedSRate.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // GST Breakdown

                  // Total Tax
                  Text(
                    "GST (15%): Rs ${totalTax.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),

                  // Final Amount After Tax
                ],
              ),
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
