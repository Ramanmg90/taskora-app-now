import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'taskora.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        email TEXT,
        full_name TEXT,
        bio TEXT,
        phone_number TEXT,
        avatar_path TEXT,
        theme_preference TEXT DEFAULT 'light',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notification_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER UNIQUE NOT NULL,
        local_notifications_enabled INTEGER DEFAULT 1,
        default_reminder_minutes INTEGER DEFAULT 15,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT DEFAULT '#7C5CFF',
        icon TEXT DEFAULT 'folder',
        owner_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (owner_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category_id INTEGER,
        priority TEXT DEFAULT 'medium',
        status TEXT DEFAULT 'pending',
        due_date TEXT NOT NULL,
        due_time TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        completed_at TEXT,
        FOREIGN KEY (owner_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_tasks_owner_status ON tasks (owner_id, status)');
    await db.execute('CREATE INDEX idx_tasks_owner_date ON tasks (owner_id, due_date)');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        offset_minutes INTEGER NOT NULL,
        is_sent INTEGER DEFAULT 0,
        notif_id INTEGER,
        UNIQUE(task_id, offset_minutes),
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // دسته‌بندی‌های پیش‌فرض سیستم (owner_id = NULL)
    final defaults = [
      {'name': 'شخصی', 'color': '#7C5CFF', 'icon': 'person'},
      {'name': 'مدرسه', 'color': '#FFB443', 'icon': 'school'},
      {'name': 'پروژه', 'color': '#FF4ECD', 'icon': 'project'},
      {'name': 'مطالعه', 'color': '#22E3F5', 'icon': 'book'},
      {'name': 'کار', 'color': '#FF5C7A', 'icon': 'work'},
      {'name': 'سایر', 'color': '#5B8CFF', 'icon': 'folder'},
    ];
    final now = DateTime.now().toIso8601String();
    for (final c in defaults) {
      await db.insert('categories', {
        'name': c['name'],
        'color': c['color'],
        'icon': c['icon'],
        'owner_id': null,
        'created_at': now,
      });
    }
  }
}
