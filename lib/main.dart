import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:inventory_management_software/res/colors.dart';
import 'package:inventory_management_software/screens/inventory_management/inventory_screen.dart';
import 'package:inventory_management_software/services/db/database_helper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home:  InventoryScreen(),
    );
  }
}
