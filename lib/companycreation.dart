import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CompanyCreationScreen extends StatefulWidget {
  const CompanyCreationScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CompanyCreationScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _createAccount() {
    print('Creating account...');

    print('Email: ${_emailController.text}');
  }

  Future<void> _saveCompanyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String companyName = _companyNameController.text.trim();
      final String address = _addressController.text.trim();
      final String email = _emailController.text.trim();
      final String phoneNumber = _phoneNumberController.text.trim();

      final uri = Uri.parse('https://varav.tutytech.in/company.php');
      final requestBody = {
        'type': 'insert',
        'companyname': companyName,
        'address': address,
        'phoneno': phoneNumber,
        'email': email,
      };

      print('Request URL: $uri');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        uri,
        body: requestBody,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Decode as a List since API returns an array
          final List<dynamic> responseData = jsonDecode(response.body);

          print("Parsed Response: $responseData");

          // Ensure the response contains at least one item
          if (responseData.isNotEmpty &&
              responseData[0] is Map<String, dynamic>) {
            final Map<String, dynamic> companyData = responseData[0];

            if (companyData.containsKey('id') && companyData['id'] != null) {
              final int companyId = companyData['id'];

              await prefs.setString('companyname', companyName);
              await prefs.setString('address', address);
              await prefs.setString('mailid', email);
              await prefs.setString('phoneno', phoneNumber);
              await prefs.setString('companyId', companyId.toString());

              print('Company created successfully: ID - $companyId');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Company created successfully!')),
              );
            } else {
              print('Unexpected Response Format: $companyData');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unexpected response format.')),
              );
            }
          } else {
            print('Unexpected Response Format: $responseData');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unexpected response format.')),
            );
          }
        } catch (jsonError) {
          print('JSON Parsing Error: $jsonError');
          print('Raw Response: ${response.body}');
        }
      } else {
        print('Request Failed. Status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create company.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create Company',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Form card
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        'Company Name',
                        _companyNameController,
                        Icons.person,
                        false,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        'Address',
                        _addressController,
                        Icons.person,
                        false,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        'Email',
                        _emailController,
                        Icons.email,
                        false,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        'PhoneNo',
                        _phoneNumberController,
                        Icons.email,
                        false,
                      ),

                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _saveCompanyData();
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sign In link
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isPassword,
  ) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
