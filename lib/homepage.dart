import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/widgets/customnavigation.dart';
import 'package:http/http.dart' as http;

class FoodGoHome extends StatefulWidget {
  const FoodGoHome({Key? key}) : super(key: key);

  @override
  _FoodGoHomeState createState() => _FoodGoHomeState();
}

class _FoodGoHomeState extends State<FoodGoHome> {
  int totalCustomerCount = 0;
  int totalProducts = 0;
  int totalOrders = 0;
  int totalBillAmount = 0;
  @override
  void initState() {
    super.initState();
    fetchCustomerData();
    fetchTotalProducts();
    fetchTotalOrders();
  }

  Future<void> fetchCustomerData() async {
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
        if (decodedResponse['totalCount'] != null) {
          setState(() {
            totalCustomerCount =
                decodedResponse['totalCount']; // Set the total customer count
          });
        }
      } else {
        throw Exception('Failed to fetch customer data');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> fetchTotalProducts() async {
    const String apiUrl = 'https://varav.tutytech.in/product.php'; // API URL

    try {
      // Prepare the request body
      final Map<String, String> requestBody = {'type': 'select'};

      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      // If the request is successful, parse the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        // Check if response contains totalCount
        if (decodedResponse.containsKey('totalCount')) {
          setState(() {
            totalProducts = decodedResponse['totalCount']; // Store total count
          });
        } else {
          throw Exception('Total count not found in response');
        }
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchTotalOrders() async {
    const String apiUrl =
        'https://varav.tutytech.in/orderconfirm.php'; // API URL

    try {
      // Prepare the request body
      final Map<String, String> requestBody = {'type': 'select'};

      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      // If the request is successful, parse the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        // Check if response contains totalCount and totalBillAmount
        if (decodedResponse.containsKey('totalCount') &&
            decodedResponse.containsKey('totalBillAmount')) {
          setState(() {
            totalOrders =
                decodedResponse['totalCount']; // Store total order count
            totalBillAmount =
                decodedResponse['totalBillAmount']; // Store total bill amount
          });
        } else {
          throw Exception('Required data not found in response');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Orders',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          CircleAvatar(backgroundImage: AssetImage('images/profile.jpg')),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1, // Ensures square shape
                children: [
                  _buildFoodCard('Total Order', totalOrders.toString()),
                  _buildFoodCard('Order Value', totalBillAmount.toString()),
                  _buildFoodCard(
                    'Total Customer',
                    totalCustomerCount.toString(),
                  ),
                  _buildFoodCard('Total Products', totalProducts.toString()),
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button in Center
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

  Widget _buildFoodCard(String name, String count) {
    return SizedBox(
      width: 60, // Reduced width
      height: 50, // Reduced height
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Light shadow
              spreadRadius: 1, // Minimal spread
              blurRadius: 6, // Soft blur effect
              offset: const Offset(2, 2), // Slight bottom-right shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  count,
                  style: const TextStyle(
                    fontSize: 35, // Kept the same
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 18, // Kept the same
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
