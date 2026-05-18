import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';

class DatabaseHelper {
  static const _databaseName = "MemoSpace.db";
  static const _databaseVersion = 1;

  static const tableCategories = 'categories';
  static const tableNotes = 'notes';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCategories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_hex TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableNotes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        category_id INTEGER,
        is_pinned INTEGER DEFAULT 0,
        reminder_date TEXT,
        images TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES $tableCategories (id) ON DELETE SET NULL
      )
    ''');
  }

  // --- Category CRUD Operations ---

  Future<int> insertCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.insert(tableCategories, category.toMap());
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableCategories);
    return List.generate(maps.length, (i) {
      return CategoryModel.fromMap(maps[i]);
    });
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.update(
      tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Note CRUD Operations ---

  Future<int> insertNote(NoteModel note) async {
    final db = await instance.database;
    return await db.insert(tableNotes, note.toMap());
  }

  Future<List<NoteModel>> getNotes() async {
    final db = await instance.database;
    // Order by pinned status first (1 before 0), then by created_at descending
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      orderBy: 'is_pinned DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return NoteModel.fromMap(maps[i]);
    });
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await instance.database;
    return await db.update(
      tableNotes,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableNotes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
