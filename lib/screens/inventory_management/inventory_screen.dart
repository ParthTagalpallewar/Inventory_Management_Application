import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_software/res/colors.dart';
import 'package:inventory_management_software/screens/app_drawer.dart';
import 'package:inventory_management_software/screens/inventory_management/product_screen.dart';
import 'package:inventory_management_software/screens/inventory_management/purchases.dart';
import 'package:inventory_management_software/services/db/inventory_dao.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final InventoryDao _inventoryDao = InventoryDao();
  List<Map<String, dynamic>> _inventoryList = [];

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    final inventory = await _inventoryDao.getInventoryWithProductName();
    setState(() {
      _inventoryList = inventory;
    });
  }

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
            onPressed: () async {
              await Get.to(() => PurchasesScreen());
              _fetchInventory();
            },
            child: const Text('Purchases', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: AppDrawer(),
      backgroundColor: Colors.black, // Set background color to black
      body: Column(
        children: [
          // Header row with column titles
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            color: Colors.grey[850], // Dark grey for header
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(child: Text("Product Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Text("Quantity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Inventory list or "No inventory" message
          Expanded(
            child: _inventoryList.isEmpty
                ? const Center(
              child: Text(
                "No inventory available",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _inventoryList.length,
              itemBuilder: (context, index) {
                var item = _inventoryList[index];
                return Card(
                  color: Colors.grey[900], // Set card color
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['product_name'],
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item['quantity'].toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
