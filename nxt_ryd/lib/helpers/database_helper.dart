import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nxtryd.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone_number TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // Create cart_items table
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        added_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Insert default products
    await _insertDefaultProducts(db);
  }

  Future<void> _insertDefaultProducts(Database db) async {
    final products = [
      {
        'id': '1',
        'name': 'Car Air Freshener',
        'price': 299.0,
        'image': '🌸',
        'description': 'Premium car air freshener',
      },
      {
        'id': '2',
        'name': 'Phone Holder',
        'price': 599.0,
        'image': '📱',
        'description': 'Universal phone holder for cars',
      },
      {
        'id': '3',
        'name': 'Car Charger',
        'price': 799.0,
        'image': '🔌',
        'description': 'Fast charging car adapter',
      },
      {
        'id': '4',
        'name': 'Seat Covers',
        'price': 1299.0,
        'image': '🪑',
        'description': 'Premium leather seat covers',
      },
      {
        'id': '5',
        'name': 'Dashboard Camera',
        'price': 2999.0,
        'image': '📹',
        'description': 'HD dashboard camera with night vision',
      },
      {
        'id': '6',
        'name': 'Car Vacuum',
        'price': 1899.0,
        'image': '🧹',
        'description': 'Portable car vacuum cleaner',
      },
    ];

    for (var product in products) {
      await db.insert('products', product);
    }
  }

  // User authentication methods
  Future<bool> registerUser({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final db = await database;
      await db.insert('users', {
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false; // User already exists or other error
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> userExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Product methods
  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product?> getProduct(String id) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Product.fromJson(result.first) : null;
  }

  // Cart methods
  Future<void> addToCart(String userEmail, String productId) async {
    final db = await database;
    
    // Check if item already exists in cart
    final existing = await db.query(
      'cart_items',
      where: 'user_email = ? AND product_id = ?',
      whereArgs: [userEmail, productId],
    );

    if (existing.isNotEmpty) {
      // Update quantity
      await db.update(
        'cart_items',
        {'quantity': (existing.first['quantity'] as int) + 1},
        where: 'user_email = ? AND product_id = ?',
        whereArgs: [userEmail, productId],
      );
    } else {
      // Insert new item
      await db.insert('cart_items', {
        'user_email': userEmail,
        'product_id': productId,
        'quantity': 1,
        'added_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userEmail) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.*, p.name, p.price, p.image, p.description
      FROM cart_items c
      JOIN products p ON c.product_id = p.id
      WHERE c.user_email = ?
      ORDER BY c.added_at DESC
    ''', [userEmail]);
  }

  Future<void> removeFromCart(String userEmail, String productId) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'user_email = ? AND product_id = ?',
      whereArgs: [userEmail, productId],
    );
  }

  Future<void> clearCart(String userEmail) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'user_email = ?',
      whereArgs: [userEmail],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}