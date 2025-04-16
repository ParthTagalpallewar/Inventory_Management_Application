import 'package:flutter/material.dart';
import 'package:inventory_management_software/screens/app_drawer.dart';
import 'package:inventory_management_software/services/db/inventory_dao.dart';
import 'package:intl/intl.dart';

class PurchasesScreen extends StatefulWidget {
  @override
  _PurchasesScreenState createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final InventoryDao _inventoryDao = InventoryDao();
  List<Map<String, dynamic>> _purchases = [];
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();


  String? dbPath;

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  Future<void> _fetchPurchases({String? query}) async {
    List<Map<String, dynamic>> purchases;
    if (query == null || query.isEmpty) {
      purchases = await _inventoryDao.getPurchasesWithProductName();
    } else {
      purchases = await _inventoryDao.getPurchasesWithProductNameFiltered(query);
    }

    setState(() {
      _purchases = purchases;
    });
  }


  void _showAddPurchaseDialog() {
    String? selectedProductId;
    String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    TextEditingController priceController = TextEditingController();
    TextEditingController distributorController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Purchase"),
          backgroundColor: Colors.black,
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _inventoryDao.getProducts(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("No Products Available", style: TextStyle(
                            color: Colors.white));
                      }
                      return DropdownButtonFormField<String>(
                        dropdownColor: Colors.black,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Select Product",
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7)),
                        ),
                        items: snapshot.data!.map((product) {
                          return DropdownMenuItem(
                            value: product['product_id'].toString(),
                            child: Text(product['product_name'],
                                style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedProductId = value;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Purchase Price",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: distributorController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Distributor Name",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Quantity",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(data: ThemeData.dark(), child: child!);
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedDate,
                              style: TextStyle(color: Colors.white)),
                          const Icon(Icons.calendar_today, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)),
                    ),
                    onPressed: () async {
                      if (selectedProductId == null ||
                          priceController.text.isEmpty ||
                          distributorController.text.isEmpty ||
                          quantityController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("All fields are required"),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }

                      await _inventoryDao.addPurchase(
                        productId: int.parse(selectedProductId!),
                        purchasePrice: double.parse(priceController.text),
                        distributorName: distributorController.text,
                        quantity: int.parse(quantityController.text),
                        purchaseDate: selectedDate,
                      );

                      await _inventoryDao.addOrUpdateInventory(productId: int.parse(selectedProductId!), quantity: int.parse(quantityController.text));

                      Navigator.pop(context); // Close dialog
                      _fetchPurchases(); // Refresh list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Purchase added successfully!"),
                            backgroundColor: Colors.green),
                      );
                    },
                    child: const Text(
                        "Add Purchase", style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by product name...',
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            _fetchPurchases(query: value);
          },
        )
            : const Text("Purchases"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _fetchPurchases(); // Reset list
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          TextButton.icon(
            onPressed: _showAddPurchaseDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add Purchase",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),

      body: Column(
        children: [
          // Header Row for Titles
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            color: Colors.grey[900], // Dark background for title row
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("Product Name", style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(child: Text("Distributor Name", style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(child: Text("Price", style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(child: Text("Quantity", style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(child: Text("Purchase Date", style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          // Purchases List
          Expanded(
            child: _purchases.isEmpty
                ? const Center(child: Text("No purchases available.",
                style: TextStyle(color: Colors.white)))
                : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _purchases.length,
              itemBuilder: (context, index) {
                var purchase = _purchases[index];
                return Card(
                  color: Colors.blueGrey[900], // Black background
                  margin: EdgeInsets.only(top: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text("${purchase['product_name']}",
                            style: TextStyle(color: Colors.white))),
                        Expanded(child: Text("${purchase['distributor_name']}",
                            style: TextStyle(color: Colors.white))),
                        Expanded(child: Text("₹${purchase['purchase_price']}",
                            style: TextStyle(color: Colors.white))),
                        Expanded(child: Text("${purchase['quantity']}",
                            style: TextStyle(color: Colors.white))),
                        Expanded(child: Text("${purchase['purchase_date']}",
                            style: TextStyle(color: Colors.white))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black, // Set entire background black
    );
  }
}