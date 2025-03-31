import 'package:flutter/material.dart';
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/widgets/customnavigation.dart';

class OrderConfirmation extends StatefulWidget {
  final String name;
  final String phoneNo;
  final String address;
  final List<Map<String, dynamic>> products;
  final double price;
  final int qty;
  final double total;
  final double billAmount, totalgst, totalamount;
  final double gstRate;

  const OrderConfirmation({
    Key? key,
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
  }) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderConfirmation> {
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
              _buildBillDetail("GST (5%)", widget.totalgst),
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
                      // Handle order confirmation
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
