import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:orderapp/companycreation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phonenoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _createAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? companyId = prefs.getString('companyId');

      if (companyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Company ID not found. Please create a company first.',
            ),
          ),
        );
        return;
      }

      final Uri userUri = Uri.parse('https://varav.tutytech.in/user.php');
      final Map<String, String> userRequestBody = {
        'type': 'insert',
        'name': _nameController.text.trim(),
        'phoneno': _phonenoController.text.trim(),
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        'companyid': companyId,
      };

      print('User Request URL: $userUri');
      print('User Request Body: ${jsonEncode(userRequestBody)}');

      final http.Response userResponse = await http.post(
        userUri,
        body: userRequestBody,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      print('User Response Status Code: ${userResponse.statusCode}');
      print('User Response Body: ${userResponse.body}');

      if (userResponse.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(userResponse.body);

        if (responseData.isNotEmpty &&
            responseData[0] is Map<String, dynamic> &&
            responseData[0].containsKey("id")) {
          String userId = responseData[0]["id"].toString();

          // Save user ID to SharedPreferences
          await prefs.setString("userId", userId);
          print("User ID saved to SharedPreferences: $userId");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User registered successfully!')),
          );

          // Optionally navigate to another page after success
          Navigator.pop(context);
        } else {
          print("User ID not found in response.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get User ID.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to register user.')),
        );
      }
    } catch (e) {
      print('User Registration Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while registering user: $e')),
      );
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
                  'SignUp',
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
                        'Name',
                        _nameController,
                        Icons.person,
                        false,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        'PhoneNo.',
                        _phonenoController,
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
                        'UserName',
                        _usernameController,
                        Icons.email,
                        false,
                      ),
                      const SizedBox(height: 15),
                      _buildPasswordField(
                        'Password',
                        _passwordController,
                        Icons.lock,
                        true,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Flexible(
                            child: _buildTextField(
                              'Companyid',
                              _nameController,
                              Icons.person,
                              false,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ), // Add spacing between TextField and button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const CompanyCreationScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Create',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createAccount,
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

                const SizedBox(height: 20),

                // Sign In link
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Navigates back to Login
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

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

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isPassword,
  ) {
    return TextField(
      controller: controller,
      obscureText:
          isPassword
              ? (label == 'Password'
                  ? _obscurePassword
                  : _obscureConfirmPassword)
              : false,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
            (label == 'Password' ? _obscurePassword : _obscureConfirmPassword)
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              if (label == 'Password') {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
