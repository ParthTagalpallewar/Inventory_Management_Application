import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:inventory_management_software/res/colors.dart';
import 'package:inventory_management_software/screens/app_drawer.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:inventory_management_software/screens/inventory_management/product_screen.dart';
import 'package:inventory_management_software/screens/inventory_management/purchases.dart';

class InventoryScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(() => ProductScreen());
            },
            child: const Text('Create Product', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Get.to(() => PurchasesScreen());
            },
            child: const Text('Purchases', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: const Center(
        child: Text(
          'Welcome to Inventory Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }


}
