import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:inventory_management_software/screens/receipt_screen.dart';
import 'package:inventory_management_software/screens/transaction_screen.dart';
import 'package:inventory_management_software/screens/inventory_management/inventory_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Center(
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.inventory),
            title: Text("Inventory Management"),
            onTap: () {
              Get.off(InventoryScreen());
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text("Accounting Transactions"),
            onTap: () {
              Get.off(Transactionsscreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text("Create Receipt"),
            onTap: () {
              Get.off(ReceiptScreen());
            },
          ),
        ],
      ),
    );
  }
}
