import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

class ContactService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contacts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT
          )
        ''');
      },
    );
  }

  Future<List<Contact>> getContacts() async {
    final db = await database;
    final rows = await db.query('contacts', orderBy: 'name ASC');
    return rows.map((row) => Contact(
      id: row['id'] as String,
      name: row['name'] as String,
      phone: row['phone'] as String,
      email: row['email'] as String? ?? '',
    )).toList();
  }

  Future<void> addContact(Contact c) async {
    final db = await database;
    await db.insert('contacts', {
      'id': c.id,
      'name': c.name,
      'phone': c.phone,
      'email': c.email,
    });
  }

  Future<void> deleteContact(String id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateContact(Contact c) async {
    final db = await database;
    await db.update(
      'contacts',
      {'name': c.name, 'phone': c.phone, 'email': c.email},
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }
}
