import 'package:flutter/material.dart';
import 'package:orderapp/companycreation.dart';
import 'package:orderapp/createledger.dart';
import 'package:orderapp/customersearchform.dart';
import 'package:orderapp/homepage.dart';
import 'package:orderapp/ledgerform.dart';
import 'package:orderapp/login.dart';
import 'package:orderapp/orderconfiramtionpage.dart';
import 'package:orderapp/products.dart';
import 'package:orderapp/reportform.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      home: products(),
    );
  }
}
