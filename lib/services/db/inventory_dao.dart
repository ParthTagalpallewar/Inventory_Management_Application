import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_software/services/db/database_helper.dart';
import 'package:inventory_management_software/services/model/receipt_model.dart';
import 'package:inventory_management_software/services/model/recepit_inventory_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/intl.dart';

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
  Future<String> getPath()async{
    final db = await _dbHelper.getDbPath();
    return db;
  }

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

  Future<List<InventoryItem>> getInventoryItemList() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT 
      inventory.inventory_id, 
      inventory.product_id, 
      products.product_name, 
      inventory.quantity
    FROM inventory
    JOIN products ON inventory.product_id = products.product_id
    ORDER BY inventory.inventory_id DESC
  ''');

    return result.map((map) => InventoryItem.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getPurchasesWithProductNameFiltered(String query) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
    SELECT purchases.*, products.product_name
    FROM purchases
    JOIN products ON purchases.product_id = products.product_id
    WHERE products.product_name LIKE ?
  ''', ['%$query%']);
  }

  Future<void> reduceInventoryQuantity(int inventoryId, int subQuantity) async {
    final Database db = await _dbHelper.database;
    await db.rawUpdate(
      '''
    UPDATE inventory 
    SET quantity = quantity - ? 
    WHERE inventory_id = ?
    ''',
      [subQuantity, inventoryId],
    );
  }

  Future<int> addReceipt(
      String customerName,
      String customerAddress,
      String mobileNumber,
      String emailAddress,
      String gstPercentage,
      String? gstIn
      ) async {
    final Database db = await _dbHelper.database;

    return await db.rawInsert(
      '''
    INSERT INTO selling_receipt_history (
      customer_name,
      customer_address,
      mobile_number,
      email_address,
      gst_percentage,
      gstin_number,
      date
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        customerName,
        customerAddress,
        mobileNumber,
        emailAddress,
        double.parse(gstPercentage), // assuming it's passed as a string
        gstIn,
        DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()
      ],
    );
  }

  Future<List<Receipt>> getAllReceipts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query('selling_receipt_history');
    return result.map((map) => Receipt.fromMap(map)).toList();
  }

  Future<List<Receipt>> getReceiptsByCustomerName(String name) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      'selling_receipt_history',
      where: 'customer_name LIKE ?',
      whereArgs: ['%$name%'],
    );

    return result.map((map) => Receipt.fromMap(map)).toList();
  }



  Future<void> addReceiptInventory(
      int receiptId,
      int inventoryId,
      String? hsnCode,
      int quantity,
      int price,
      ) async {
    final Database db = await _dbHelper.database;

    await db.rawInsert(
      '''
    INSERT INTO selling_inventory_history (
      receipt_id,
      inventory_id,
      hsn_code,
      selling_qty,
      selling_price
    ) VALUES (?, ?, ?, ?, ?)
    ''',
      [
        receiptId,
        inventoryId,
        hsnCode,
        quantity,
        price,
      ],
    );
  }

  Future<List<InventoryItem>> getInventoryItemsByReceiptId(int receiptId) async {
    final Database db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
    SELECT 
      sih.inventory_id,
      prod.product_name,
      inv.quantity AS available_quantity,
      sih.selling_qty AS selling_quantity,
      sih.selling_price,
      sih.hsn_code
    FROM selling_inventory_history sih
    JOIN inventory inv ON sih.inventory_id = inv.inventory_id
    JOIN products prod ON inv.product_id = prod.product_id
    WHERE sih.receipt_id = ?
    ''',
      [receiptId],
    );

    return result.map((map) => InventoryItem.secondFromMap(map)).toList();
  }






}
