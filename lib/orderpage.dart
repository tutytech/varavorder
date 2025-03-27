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
  double numericPrice = 0;
  double totalPrice = 0;
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
                    'price':
                        product['salesrate'].toString(), // Ensure it's a string
                    'qty':
                        int.tryParse(product['salesqty'].toString()) ??
                        0, // Ensure it's an integer
                    'unit': product['salesunit'].toString(),
                    'mrp': double.tryParse(product['mrp'].toString()) ?? 0.0,
                    'salesRate':
                        double.tryParse(product['salesrate'].toString()) ?? 0.0,
                    'purRate':
                        double.tryParse(product['purchaserate'].toString()) ??
                        0.0,
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
      if (newQty >= 0) {
        quantity = newQty;
        totalPrice = numericPrice * quantity; // Update totalPrice
        if (!fromTextField) {
          _controller.text = quantity.toString();
        }
      }
    });
  }

  double getNumericPrice(String price) {
    return double.parse(price.replaceAll(RegExp(r'[^\d.]'), ''));
  }

  double calculateSRate(double price) {
    return (price * 100) / (100 + gstPer);
  }

  double calculateTotal() {
    double total = 0.0;
    for (var product in productList) {
      double price = getNumericPrice(product['price'].toString());

      // Use the local 'quantity' instead of 'product['qty']'
      double totalPrice = price * quantity;

      double calculatedSRate = quantity > 0 ? calculateSRate(totalPrice) : 0.0;
      total += calculatedSRate;
    }
    return total;
  }

  double calculateGST(double amount) {
    return amount * 0.05; // 5% GST
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = calculateTotal(); // Now dynamically calculated

    double cgst = calculateGST(totalAmount);
    double sgst = calculateGST(totalAmount);
    double igst = calculateGST(totalAmount);
    double totalWithGST = totalAmount + cgst + sgst + igst;
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
                        product['qty'] as int,
                        product['unit'] as String,
                        product['mrp'] as double,
                        product['salesRate'] as double,
                        product['purRate'] as double,
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
                      ],
                    ),
                    const Divider(),
                    billDetailRow(
                      "Total",
                      "Rs.${totalAmount.toStringAsFixed(2)}",
                    ),
                    billDetailRow("CGST (5%)", "Rs.${cgst.toStringAsFixed(2)}"),
                    billDetailRow("SGST (5%)", "Rs.${sgst.toStringAsFixed(2)}"),
                    billDetailRow("IGST (5%)", "Rs.${igst.toStringAsFixed(2)}"),
                    const Divider(),
                    billDetailRow(
                      "To Pay",
                      "Rs.${totalWithGST.toStringAsFixed(2)}",
                      isBold: true,
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

  Widget productItem(
    String name,
    String price,
    int qty,
    String unit,
    double mrp,
    double salesRate,
    double purRate,
  ) {
    numericPrice = getNumericPrice(price);
    print('Numeric Price extracted from "$price": $numericPrice');
    totalPrice = numericPrice * quantity;

    // Calculate 5% SGST, 5% CGST, 5% TGST
    double sgst = totalPrice * 0.05;
    double cgst = totalPrice * 0.05;
    double tgst = totalPrice * 0.05;

    // Total Tax (15% of total price)
    double totalTax = sgst + cgst + tgst;

    // Final amount after adding tax
    double finalAmount = totalPrice + totalTax;

    double calculatedSRate = quantity > 0 ? calculateSRate(totalPrice) : 0.0;

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
          // Image Placeholder + Product Details Centered
          Column(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Image.asset(
                  'images/profile.jpg', // Replace with your local placeholder image
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),

          Column(
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text("MRP: $mrp", style: const TextStyle(color: Colors.red)),
              Text("PR: $purRate", style: const TextStyle(color: Colors.red)),
            ],
          ),

          // Quantity, Pricing, and Tax Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Unit Text
              Text(unit, style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 6),

              // Quantity Control Row
              SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => _updateQty(quantity - 1),
                      icon: Icon(Icons.remove, color: Colors.red),
                      padding: EdgeInsets.zero,
                    ),
                    SizedBox(
                      width: 40,
                      height: 30,
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          // This updates totalPrice live when typing
                          int? enteredQty = int.tryParse(value);
                          if (enteredQty != null) {
                            _updateQty(enteredQty, fromTextField: true);
                          }
                        },
                        onSubmitted: (value) {
                          int? enteredQty = int.tryParse(value);
                          if (enteredQty != null) {
                            _updateQty(enteredQty, fromTextField: true);
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 5),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _updateQty(quantity + 1),
                      icon: Icon(Icons.add, color: Colors.red),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 6),

              // Total Price
              Text(
                "Rs ${totalPrice.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 4),

              // GST Text
              Text(
                "GST (15%): Rs ${totalTax.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
