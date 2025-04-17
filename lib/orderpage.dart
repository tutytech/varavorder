import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/orderconfiramtionpage.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  final String? name, id;
  final String? phoneNo;
  final String? address;
  final List<Map<String, dynamic>>? customers;

  const OrderPage({
    Key? key,
    this.name,
    this.customers,
    this.id,
    this.phoneNo,
    this.address,
  }) : super(key: key);

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
  List<Map<String, dynamic>> cartItems = [];

  List<Map<String, dynamic>> productList = [];
  double gstPer = 5.0;
  int quantity = 0; // Default quantity starts from 0
  Map<int, TextEditingController> controllers = {};
  List<Map<String, dynamic>> selectedProducts = [];

  double numericPrice = 0;
  double totalPrice = 0;
  double totalCGST = 0;
  double totalSGST = 0;
  double totalIGST = 0;
  double gstRate = 0;
  double gstAmount = 0;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    const String _baseUrl = 'https://varav.tutytech.in/product.php';

    try {
      // Get companyId from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? companyId = prefs.getString('companyid');

      if (companyId == null) {
        print('companyId not found in SharedPreferences');
        return;
      }

      final Map<String, String> requestBody = {
        'type': 'select',
        'companyid': companyId,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        final decodedResponse = json.decode(response.body);
        print('Decoded Response: $decodedResponse');

        if (decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey('data')) {
          final List<dynamic> productData = decodedResponse['data'];

          if (productData.isEmpty) {
            throw Exception('No products found');
          }

          setState(() {
            productList =
                productData.map<Map<String, dynamic>>((product) {
                  int productId = int.tryParse(product['id'].toString()) ?? 0;
                  double gstRate =
                      double.tryParse(product['gst'].toString()) ?? 0.0;

                  controllers[productId] = TextEditingController(
                    text: quantity.toString(),
                  );

                  return {
                    'id': productId,
                    'name': product['productname'].toString(),
                    'price':
                        double.tryParse(product['salesrate'].toString()) ?? 0.0,
                    'qty': quantity,
                    'unit': product['salesunit'].toString(),
                    'mrp': double.tryParse(product['mrp'].toString()) ?? 0.0,
                    'salesRate':
                        double.tryParse(product['salesrate'].toString()) ?? 0.0,
                    'purRate':
                        double.tryParse(product['purchaserate'].toString()) ??
                        0.0,
                    'gst': gstRate,
                  };
                }).toList();
          });
        } else {
          throw Exception('Invalid response format');
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

  double getGSTPercentage() {
    if (productList.isNotEmpty) {
      return double.tryParse(productList.first['gst'].toString()) ?? 0.0;
    }
    return 0.0;
  }

  void _updateQty(int productId, int newQty, {bool fromTextField = false}) {
    setState(() {
      if (newQty >= 0) {
        // ✅ Find the product in the list and update its quantity
        int index = productList.indexWhere(
          (product) => product['id'] == productId,
        );
        if (index != -1) {
          productList[index]['qty'] = newQty;

          // ✅ Update the TextField controller value
          if (!fromTextField) {
            controllers[productId]?.text = newQty.toString();
          }

          // ✅ Add or update product in selectedProducts
          int selectedIndex = selectedProducts.indexWhere(
            (product) => product['id'] == productId,
          );

          if (selectedIndex != -1) {
            // ✅ Update existing product quantity
            selectedProducts[selectedIndex]['qty'] = newQty;
            selectedProducts[selectedIndex]['total'] =
                newQty * productList[index]['price'];
          } else {
            // ✅ Add new product to selectedProducts
            selectedProducts.add({
              'id': productList[index]['id'],
              'name': productList[index]['name'],
              'qty': newQty,
              'price': productList[index]['price'],
              'gst': productList[index]['gst'],
              'total': newQty * productList[index]['price'],
            });
          }

          // ✅ Remove products with 0 quantity
          selectedProducts.removeWhere((p) => p['qty'] == 0);
        }
      }
      print("Updated selectedProducts: $selectedProducts"); // ✅ Debugging
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
      int qty = product['qty'] ?? 0;
      double totalPrice = price * qty; // Directly use totalPrice

      print(
        "Product: ${product['name']}, Price: $price, Qty: $qty, TotalPrice: $totalPrice",
      );

      total += totalPrice; // Sum up totalPrice directly
    }
    print("Final Total: $total");
    return total;
  }

  double calculateTotalGST() {
    double totalGST = 0.0;

    for (var product in productList) {
      double price = double.tryParse(product['salesRate'].toString()) ?? 0.0;
      int qty = product['qty'] ?? 0;
      double gstRate = double.tryParse(product['gst'].toString()) ?? 0.0;

      double totalPrice = price * qty; // Total price before GST
      double gstAmount =
          (totalPrice * gstRate) / 100; // Calculate GST using API value

      totalGST += gstAmount; // Sum up total GST
    }

    // Calculate total CGST and SGST by dividing the total GST rate by 2
    totalCGST = totalGST / 2;
    totalSGST = totalGST / 2;
    totalIGST = 0; // IGST is set to 0

    print("Total GST Amount: $totalGST");
    print("CGST: $totalCGST, SGST: $totalSGST, IGST: $totalIGST");

    return totalGST;
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = calculateTotal(); // Now dynamically calculated

    double cgst = calculateTotalGST();
    double sgst = calculateTotalGST();
    double igst = calculateTotalGST();
    double totalWithGST = totalAmount + totalCGST + totalSGST + totalIGST;
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
                        product['id'] as int,
                        product['name'] as String,
                        product['price'].toString(),

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
                    billDetailRow(
                      "CGST ",
                      "Rs.${totalCGST.toStringAsFixed(2)}",
                    ),
                    billDetailRow(
                      "SGST ",
                      "Rs.${totalSGST.toStringAsFixed(2)}",
                    ),
                    billDetailRow(
                      "IGST ",
                      "Rs.${totalIGST.toStringAsFixed(2)}",
                    ),
                    const Divider(),
                    billDetailRow(
                      "Bill Amount",
                      "Rs.${totalWithGST.toStringAsFixed(2)}",
                      isBold: true,
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (productList.isNotEmpty) {
                          Map<String, dynamic> selectedProduct =
                              productList[0]; // Selecting first product
                          print("Selected Products: $selectedProducts");

                          print("ID: ${widget.id}");
                          print("Name: ${widget.name}");
                          print("Phone No: ${widget.phoneNo}");
                          print("Address: ${widget.address}");
                          print("Selected Products: $selectedProducts");
                          print(
                            "Selected Product Price: ${selectedProduct['price']}",
                          );
                          print(
                            "Selected Product Qty: ${selectedProduct['qty']}",
                          );
                          print(
                            "Total (qty * price): ${selectedProduct['qty'] * selectedProduct['price']}",
                          );
                          print("Total Amount: $totalAmount");
                          print("GST Rate: ${selectedProduct['gst']}");
                          print("Total CGST: $totalCGST");
                          print("Total SGST: $totalSGST");
                          print("Total IGST: $totalIGST");
                          print(
                            "Total GST: ${totalCGST + totalSGST + totalIGST}",
                          );
                          print("Total Amount with GST: $totalWithGST");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => OrderConfirmation(
                                    id: widget.id!,
                                    name: widget.name!,
                                    phoneNo: widget.phoneNo!,
                                    address: widget.address!,
                                    products: selectedProducts,
                                    price: selectedProduct['price'],
                                    qty: selectedProduct['qty'],
                                    total:
                                        selectedProduct['qty'] *
                                        selectedProduct['price'],
                                    billAmount: totalAmount,
                                    gstRate: selectedProduct['gst'],
                                    totalcgst: totalCGST,
                                    totalsgst: totalSGST,
                                    totaligst: totalIGST,
                                    totalgst: totalCGST + totalSGST + totalIGST,
                                    totalamount: totalWithGST,
                                  ),
                            ),
                          );
                        } else {
                          print("No product selected!");
                        }
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
    int productId,
    String name,
    String price,
    String unit,
    double mrp,
    double salesRate,
    double purRate,
  ) {
    int qty =
        productList.firstWhere(
          (product) => product['id'] == productId,
          orElse: () => {'qty': 0},
        )['qty'];

    double numericPrice = getNumericPrice(price);
    double totalPrice = numericPrice * qty;
    double sgst = totalPrice * 0.05;
    double cgst = totalPrice * 0.05;
    double tgst = totalPrice * 0.05;
    double totalTax = sgst + cgst + tgst;
    double finalAmount = totalPrice + totalTax;

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
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset('images/rectangle.png', fit: BoxFit.cover),
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

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(unit, style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 6),

              // Quantity Control Row
              SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed:
                          () => _updateQty(
                            productId,
                            qty - 1,
                          ), // ✅ Updates dynamically
                      icon: Icon(Icons.remove, color: Colors.red),
                      padding: EdgeInsets.zero,
                    ),
                    SizedBox(
                      width: 40,
                      height: 30,
                      child: TextField(
                        controller: controllers[productId],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          int? enteredQty = int.tryParse(value);
                          if (enteredQty != null) {
                            _updateQty(
                              productId,
                              enteredQty,
                              fromTextField: true,
                            );
                          }
                        },
                        onSubmitted: (value) {
                          int? enteredQty = int.tryParse(value);
                          if (enteredQty != null) {
                            _updateQty(
                              productId,
                              enteredQty,
                              fromTextField: true,
                            );
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
                      onPressed:
                          () => _updateQty(
                            productId,
                            qty + 1,
                          ), // ✅ Updates dynamically
                      icon: Icon(Icons.add, color: Colors.red),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 6),

              Text(
                "Rs ${totalPrice.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 4),
              Builder(
                builder: (context) {
                  // Find the correct GST rate for this product
                  double gstRate =
                      productList.firstWhere(
                        (product) => product['id'] == productId,
                      )['gst'];

                  // Calculate GST amount
                  double gstAmount = (totalPrice * gstRate) / 100;

                  return Text(
                    "GST (${gstRate.toStringAsFixed(2)}%): Rs ${gstAmount.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  );
                },
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
