import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_software/services/db/inventory_dao.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final InventoryDao _inventoryDao = InventoryDao();
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  /// Fetch products from DB
  void _fetchProducts() async {
    List<Map<String, dynamic>> products = await _inventoryDao.getProducts();
    setState(() {
      _products = products;
    });
  }

  /// Show Add Product Dialog
  void _showAddProductDialog() {
    TextEditingController _productController = TextEditingController();

    Get.defaultDialog(
      title: "Add Product",
      backgroundColor: Colors.grey[900],
      titleStyle: const TextStyle(color: Colors.white),
      content: Column(
        children: [
          TextField(
            cursorColor: Colors.white70,
            controller: _productController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Product Name",
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black), // Black border color
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black), // Black border when not focused
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Thicker black border when focused
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              String productName = _productController.text.trim();
              if (productName.isNotEmpty) {
                int? result = await _inventoryDao.addProduct(productName);
                if (result != null) {
                  _fetchProducts();
                  Get.back();
                  Get.snackbar("Success", "Product added successfully!",
                      snackPosition: SnackPosition.BOTTOM);
                } else {
                  Get.snackbar("Error", "Product already exists!",
                      snackPosition: SnackPosition.BOTTOM);
                }
              }
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)
                )
            ),
            child: const Text(
              "Add",
              style: TextStyle(
                color: Colors.white70
              ),
            ),

          )
        ],
      ),
    );
  }

  void _deleteProduct(int productId) {
    Get.defaultDialog(
      title: "Confirm Delete",
      middleText: "Are you sure you want to delete this product?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade300, // Lighter red color
      radius: 7, // Rounded corners for the dialog
      onConfirm: () async {
        await _inventoryDao.deleteProduct(productId);
        _fetchProducts();
        Get.back(); // Close dialog
        Get.snackbar("Deleted", "Product removed successfully!",
            snackPosition: SnackPosition.BOTTOM);
      },
      onCancel: () {
        Get.back(); // Close dialog on cancel
      },
    );
  }




  /// Edit Product Name
  void _editProduct(int productId, String currentName) {
    TextEditingController _editController =
    TextEditingController(text: currentName);

    Get.defaultDialog(
      title: "Edit Product",
      backgroundColor: Colors.grey[900],
      titleStyle: TextStyle(color: Colors.white),
      content: Column(
        children: [
          TextField(
            cursorColor: Colors.white70,
            controller: _editController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Product Name",
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              String newName = _editController.text.trim();
              if (newName.isNotEmpty) {
                await _inventoryDao.updateProduct(productId, newName);
                _fetchProducts();
                Get.back();
                Get.snackbar("Updated", "Product updated successfully!",
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)
                )
            ),
            child: const Text("Update", style: TextStyle(color: Colors.white70),),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for modern look
      appBar: AppBar(
        title: Text('Products', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          TextButton.icon(
            onPressed: _showAddProductDialog,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('Add Product', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _products.isEmpty
            ? Center(
          child: Text(
            'No products available.',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return Card(
              color: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                title: Text(
                  "${product['product_id']}    ${product['product_name']}",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _editProduct(product['product_id'], product['product_name']),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deleteProduct(product['product_id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
