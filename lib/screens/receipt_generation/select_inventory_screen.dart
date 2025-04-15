import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:inventory_management_software/services/db/inventory_dao.dart';
import 'package:inventory_management_software/services/model/recepit_inventory_model.dart';
import 'gst_screen.dart'; // the next screen to navigate to

class SelectInventoryScreen extends StatefulWidget {
  final String name;
  final String address;
  final String emailAddress;
  final String mobile;
  final String gstin;

  const SelectInventoryScreen({
    super.key,
    required this.name,
    required this.address,
    required this.emailAddress,
    required this.mobile,
    required this.gstin,
  });

  @override
  State<SelectInventoryScreen> createState() => _SelectInventoryScreenState();
}

class _SelectInventoryScreenState extends State<SelectInventoryScreen> {
  List<InventoryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final InventoryDao _inventoryDao = InventoryDao();
    final items = await _inventoryDao.getInventoryItemList(); // your DB call
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  void _goToGSTScreen() {
    final selectedItems = _items.where((item) => item.sellingQuantity > 0).toList();

    for(int i=0; i<_items.length; i++){
      if(_items[i].sellingQuantity > _items[i].availableQuantity){
        Get.snackbar("Warning", "Selling Quantity Can Not be More than Available Quantity");
        return;
      }
    }

    Get.off(GSTScreen(
      userName: widget.name,
      address: widget.address,
      emailAddress: widget.emailAddress,
      mobile: widget.mobile,
      gstin: widget.gstin,
      selectedItems: selectedItems,
    ),);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Select Inventory')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Available Quantity: ${item.availableQuantity}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.sellingQuantity.toString(),
                                  decoration: const InputDecoration(labelText: 'Selling Quantity'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      item.sellingQuantity = int.tryParse(val) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.sellingPrice.toString(),
                                  decoration: const InputDecoration(labelText: 'Selling Price'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      item.sellingPrice = int.tryParse(val) ?? 0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.hsnCode ?? '',
                                  decoration: const InputDecoration(labelText: 'HSN Code'),
                                  onChanged: (val) {
                                    setState(() {
                                      item.hsnCode = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToGSTScreen,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: const Text('Select GST Percentage', style: TextStyle(color: Colors.white),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
