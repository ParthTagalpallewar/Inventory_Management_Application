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

}
