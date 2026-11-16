import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';
import '../models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      version: 3, // Naikkan versi database menjadi 3 untuk memperbarui skema
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // KODE LAMA
    /*
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        isDone INTEGER NOT NULL DEFAULT 0,
        deadline TEXT 
      )
    ''');
    */

    // KODE BARU UNTUK SOAL 5 (Buat tabel categories & relasi)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        isDone INTEGER NOT NULL DEFAULT 0,
        deadline TEXT,
        categoryId INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Masukkan beberapa kategori default agar langsung bisa diuji
    await db.insert('categories', {'name': 'Pekerjaan'});
    await db.insert('categories', {'name': 'Pribadi'});
    await db.insert('categories', {'name': 'Pendidikan'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE todos ADD COLUMN deadline TEXT');
    }
    // KODE BARU UNTUK UPGRADE KE VERSI 3
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');
      await db.execute('ALTER TABLE todos ADD COLUMN categoryId INTEGER');
    }
  }

  // KODE BARU UNTUK SOAL 5 (CRUD Kategori)
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // KODE LAMA
  /*
  Future<List<Todo>> getFilteredTodos({bool? isDone, String keyword = ''}) async {
    ...
  }
  */

  // Mengambil satu kategori berdasarkan ID
  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  // --- KODE BARU UNTUK SOAL 5 (Filter dengan tambahan kategori & JOIN) ---
  Future<List<Todo>> getFilteredTodos({
    bool? isDone,
    String keyword = '',
    int? categoryId,
  }) async {
    final db = await database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (isDone != null) {
      whereClause += ' AND t.isDone = ?';
      whereArgs.add(isDone ? 1 : 0);
    }

    if (keyword.isNotEmpty) {
      whereClause += ' AND t.title LIKE ?';
      whereArgs.add('%$keyword%');
    }

    // Filter berdasarkan kategori (Soal 5)
    if (categoryId != null) {
      whereClause += ' AND t.categoryId = ?';
      whereArgs.add(categoryId);
    }

    // Menggunakan LEFT JOIN untuk mengambil nama kategori bersama data todo
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, c.name as categoryName 
      FROM todos t
      LEFT JOIN categories c ON t.categoryId = c.id
      WHERE $whereClause
      ORDER BY t.createdAt DESC
    ''', whereArgs);

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  Future<Todo?> getTodoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Todo.fromMap(maps.first);
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> toggleTodoStatus(int id, bool isDone) async {
    final db = await database;
    return await db.update(
      'todos',
      {'isDone': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearCompletedTodos() async {
    final db = await database;
    return await db.delete('todos', where: 'isDone = ?', whereArgs: [1]);
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
