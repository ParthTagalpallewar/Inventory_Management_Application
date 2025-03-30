import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:inventory_management_software/res/colors.dart';
import 'package:inventory_management_software/screens/inventory_management/inventory_screen.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: appTheme,
      home:  InventoryScreen(),
    );
  }
}
