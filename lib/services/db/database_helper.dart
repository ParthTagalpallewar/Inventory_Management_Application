import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Required for Windows & Linux
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    String path = join(await getDatabasesPath(), 'inventory.db');


    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  }

  Future<String> getDbPath() async{
    return join(await getDatabasesPath(), 'inventory.db');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE products (
      product_id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_name TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE purchases (
      purchase_id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL,
      purchase_price REAL NOT NULL,
      distributor_name TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      purchase_date TEXT NOT NULL,
      FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
    );
  ''');

    await db.execute('''
    CREATE TABLE inventory (
      inventory_id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
  CREATE TABLE selling_receipt_history (
    receipt_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT NOT NULL,
    customer_address TEXT NOT NULL,
    mobile_number TEXT NOT NULL,
    email_address TEXT NOT NULL,
    gst_percentage REAL NOT NULL,
    gstin_number TEXT,
    date TEXT
  )
''');

    await db.execute('''
  CREATE TABLE selling_inventory_history (
    selling_inventory_id INTEGER PRIMARY KEY AUTOINCREMENT,
    receipt_id INTEGER NOT NULL,
    inventory_id INTEGER NOT NULL,
    hsn_code TEXT,
    selling_qty INTEGER NOT NULL,
    selling_price REAL NOT NULL,
    FOREIGN KEY (receipt_id) REFERENCES selling_receipt_history(receipt_id),
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id)
  )
''');

  }

}
