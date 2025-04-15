class InventoryItem {
  final int inventoryId;
  final String productName;
  final int availableQuantity;
  int sellingQuantity;
  int sellingPrice;
  String? hsnCode;

  InventoryItem({
    required this.inventoryId,
    required this.productName,
    this.availableQuantity = 0,
    this.sellingQuantity = 0,
    this.sellingPrice = 0,
    this.hsnCode ,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      inventoryId: map['inventory_id'],
      productName: map['product_name'],
      availableQuantity: map['quantity'] ?? 0,
      sellingQuantity: 0, // default
      sellingPrice: 0, // default
      hsnCode: map['HSN_code'], // if you have this field in DB
    );
  }

  factory InventoryItem.secondFromMap(Map<String, dynamic> map) {
    return InventoryItem(
      inventoryId: map['inventory_id'],
      productName: map['product_name'],
      availableQuantity: map['available_quantity'] ?? 0,
      sellingQuantity: map['selling_quantity'] ?? 0,
      sellingPrice: (map['selling_price'] as num).toInt(),
      hsnCode: map['hsn_code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inventory_id': inventoryId,
      'product_name': productName,
      'available_quantity': availableQuantity,
      'selling_quantity': sellingQuantity,
      'selling_price': sellingPrice,
      'HSN_code': hsnCode,
    };
  }
}
