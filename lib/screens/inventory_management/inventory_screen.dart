import 'package:flutter/material.dart';
import 'package:inventory_management_software/res/colors.dart';
import 'package:inventory_management_software/screens/app_drawer.dart';

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
              _showCreateProductDialog(context);
            },
            child: const Text('Create Product', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              // Handle Add Product action
            },
            child: const Text('Add Product', style: TextStyle(color: Colors.white)),
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

  void _showCreateProductDialog(BuildContext context) {
    TextEditingController productController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Product'),
          content: TextField(
            controller: productController,
            decoration: const InputDecoration(
              hintText: 'Enter product name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String productName = productController.text.trim();
                if (productName.isNotEmpty) {

                  

                  Navigator.pop(context); // Close dialog
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
