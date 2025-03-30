import 'package:inventory_management_software/services/db/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class InventoryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Add a new product
  Future<int> addProduct(String productName) async {
    final db = await _dbHelper.database;
    return await db.insert('products', {'product_name': productName});
  }

  /// Get all products
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await _dbHelper.database;
    return await db.query('products');
  }

  /// Get a product by ID
  Future<Map<String, dynamic>?> getProductById(int productId) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> result = await db.query(
      'products',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateProduct(int id, String newName) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update('products', {'product_name': newName},
        where: 'product_id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('products', where: 'product_id = ?', whereArgs: [id]);
  }


  //purchases

  Future<List<Map<String, dynamic>>> getPurchasesWithProductName() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT p.purchase_id, p.product_id, pr.product_name, p.purchase_price, 
             p.distributor_name, p.quantity, p.purchase_date
      FROM purchases p
      JOIN products pr ON p.product_id = pr.product_id
      ORDER BY p.purchase_date DESC
    ''');
  }

  /// ✅ 2. Add a new purchase
  Future<int> addPurchase({
    required int productId,
    required double purchasePrice,
    required String distributorName,
    required int quantity,
    required String purchaseDate, // Format: YYYY-MM-DD
  }) async {
    final db = await _dbHelper.database;
    return await db.insert('purchases', {
      'product_id': productId,
      'purchase_price': purchasePrice,
      'distributor_name': distributorName,
      'quantity': quantity,
      'purchase_date': purchaseDate,
    });
  }

  /// ✅ 3. Get a purchase by ID
  Future<Map<String, dynamic>?> getPurchaseById(int purchaseId) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> result = await db.query(
      'purchases',
      where: 'purchase_id = ?',
      whereArgs: [purchaseId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> addOrUpdateInventory({
    required int productId,
    required int quantity,
  }) async {
    final db = await _dbHelper.database; // Get database instance

    // Check if the product_id already exists in inventory
    final existing = await db.query(
      'inventory',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    if (existing.isNotEmpty) {
      // If exists, update the quantity
      int prevQuantity = (existing.first['quantity'] as int);
      await db.update(
        'inventory',
        {'quantity': prevQuantity + quantity}, // Append quantity
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } else {
      // If not exists, insert new entry
      await db.insert(
        'inventory',
        {'product_id': productId, 'quantity': quantity},
      );
    }
  }

  Future<List<Map<String, dynamic>>> getInventoryWithProductName() async {
    final Database db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        inventory.inventory_id, 
        inventory.product_id, 
        products.product_name, 
        inventory.quantity 
      FROM inventory
      JOIN products ON inventory.product_id = products.product_id
      ORDER BY inventory.inventory_id DESC
    ''');
  }



}
