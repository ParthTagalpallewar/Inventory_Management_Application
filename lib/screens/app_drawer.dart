import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:inventory_management_software/screens/generated_receipts/selling_history.dart';
import 'package:inventory_management_software/screens/receipt_generation/user_input_screen.dart';
import 'package:inventory_management_software/screens/inventory_management/inventory_screen.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<String> getDatabasePath() async {
  final dbPath = await getDatabasesPath();
  return join(dbPath, 'inventory.db'); // Replace with your DB name
}
Future<String> getBackupPath() async {
  // Get the base "Documents" directory
  final documentsDir = await getApplicationDocumentsDirectory();

  // Create the full path: Documents/inventory_management_system/backup
  final backupDir = Directory(join(
    documentsDir.path,
    'inventory_management_system',
    'backup',
  ));

  // Ensure the directory exists
  if (!await backupDir.exists()) {
    await backupDir.create(recursive: true);
  }

  // Return the full path to the backup database file
  return join(backupDir.path, 'backup_database.db');
}
Future<void> backupDatabase() async {
  final originalDbPath = await getDatabasePath();
  final backupDbPath = await getBackupPath();

  final originalDbFile = File(originalDbPath);
  final backupDbFile = File(backupDbPath);

  if (await originalDbFile.exists()) {
    await originalDbFile.copy(backupDbFile.path);
    Get.snackbar("Success", "Backup Taken Successfully");
  } else {
    Get.snackbar("Success", "Failed to take backup");

  }
}
// Future<void> restoreDatabase() async {
//   final originalDbPath = await getDatabasePath();
//   final backupDbPath = await getBackupPath();
//
//   final originalDbFile = File(originalDbPath);
//   final backupDbFile = File(backupDbPath);
//
//   if (await backupDbFile.exists()) {
//     await backupDbFile.copy(originalDbFile.path);
//     print("Database restored from backup.");
//   } else {
//     print("Backup file not found.");
//   }
// }

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
            leading: const Icon(Icons.receipt),
            title: const Text("Create Receipt"),
            onTap: () {
              Get.off(UserInputScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Selling History"),
            onTap: () {
              Get.off(ReceiptListScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Take Backup"),
            onTap: (){
              backupDatabase();
            },
          )
        ],
      ),
    );
  }


}
