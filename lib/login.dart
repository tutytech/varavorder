import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:orderapp/createaccount.dart';
import 'package:orderapp/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    Timer(const Duration(seconds: 20), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Stack(
        children: [
          // Subtle background circles (top left)
          Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: const Offset(-100, -100),
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Subtle background circles (bottom right)
          Align(
            alignment: Alignment.bottomRight,
            child: Transform.translate(
              offset: const Offset(150, 150),
              child: Container(
                height: 350,
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Additional smaller circle (top right)
          Align(
            alignment: Alignment.topRight,
            child: Transform.translate(
              offset: const Offset(-50, 100),
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Main content (Welcome text + logo)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image(image: AssetImage("assets/images/svg.png")),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Let\'s get started!',
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Top wave shape
class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

Future<void> _login() async {
  final String email = _emailController.text.trim();
  final String password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Missing Fields"),
        content: const Text("Please enter both email and password."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
    return;
  }

  final String url = "https://varav.tutytech.in/user.php";

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        "type": "login",
        "username": email,
        "password": password,
      },
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
    );

    print('Login Response Status Code: ${response.statusCode}');
    print('Login Response Body: ${response.body.isEmpty ? "EMPTY RESPONSE" : response.body}');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Server Error"),
            content: const Text("Login failed. Server returned an empty response."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      final List<dynamic> responseData = jsonDecode(response.body);

      if (responseData.isNotEmpty &&
          responseData[0] is Map<String, dynamic> &&
          responseData[0]["id"] != null) {
        String userId = responseData[0]["id"].toString();
        String companyId = responseData[0]["companyid"].toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("userId", userId);
        await prefs.setString("companyid", companyId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FoodGoHome()),
        );
        print('Login Successfully');
      } else {
        // Show dialog with Register button
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Login Failed"),
            content: const Text("Username and password do not exist. Please register."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateAccountScreen()), // Replace with your register page
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Register"),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Login failed. Please try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    print('Login Error: $e');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exception"),
        content: Text("An error occurred: $e"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section with logo
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              color: Colors.red,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 140,
                      width: 140,

                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image(
                          image: AssetImage("assets/images/svg.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // White Card Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Add the rest of your fields and buttons here
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'UserName',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        _login();
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OR divider
                  const Text('Or', style: TextStyle(color: Colors.black54)),

                  const SizedBox(height: 20),

                  // Social Media Icons

                  // Register Text
                  RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to CreateAccountScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const CreateAccountScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: const Center(child: Text('Welcome to the Home Page!')),
    );
  }
}
