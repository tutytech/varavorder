import 'package:flutter/material.dart';
import 'package:orderapp/homepage.dart';
import 'package:orderapp/ledgerform.dart';
import 'package:orderapp/products.dart';
import 'package:orderapp/reportform.dart';

import '../homepage.dart';
import '../ledgerform.dart';
import '../orderreportview.dart';
import '../productlist.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Function(int) onItemSelected;

  const CustomBottomNavBar({Key? key, required this.onItemSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed:
                  () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FoodGoHome()),
                    ),
                  },
            ),
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.inventory, color: Colors.white),
              onPressed:
                  () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => productlist()),
                    ),
                  },
            ),
            const SizedBox(width: 40), // Space for floating button
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.group, color: Colors.white),
              onPressed:
                  () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Ledger()),
                    ),
                  },
            ),
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.dns, color: Colors.white),
              onPressed:
                  () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Orderreportview(),
                      ),
                    ),
                  },
            ),
          ],
        ),
      ),
    );
  }
}
