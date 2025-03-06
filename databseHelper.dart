import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static Database? _database;

  // Singleton pattern
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'card_organizer.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      // Create Folders table
      await db.execute('''
        CREATE TABLE Folders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          timestamp TEXT
        );
      ''');

      // Create Cards table
      await db.execute('''
        CREATE TABLE Cards(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          suit TEXT,
          image_url TEXT,
          folder_id INTEGER,
          FOREIGN KEY (folder_id) REFERENCES Folders(id)
        );
      ''');

      // Prepopulate cards (1 to 13 for each suit)
      for (var suit in ['Hearts', 'Spades', 'Diamonds', 'Clubs']) {
        for (var i = 1; i <= 13; i++) {
          String cardName = '$i of $suit';
          String imageUrl = 'https://example.com/images/$i_$suit.png'; // Example image URL
          await db.insert('Cards', {
            'name': cardName,
            'suit': suit,
            'image_url': imageUrl,
            'folder_id': _getFolderId(suit),
          });
        }
      }
    });
  }

  // Fetch folder ID by name
  Future<int> _getFolderId(String name) async {
    final db = await database;
    var result = await db.query('Folders', where: 'name = ?', whereArgs: [name]);
    return result.isNotEmpty ? result.first['id'] : -1;
  }

  // Fetch all folders
  Future<List<Map<String, dynamic>>> getFolders() async {
    final db = await database;
    return await db.query('Folders');
  }

  // Fetch all cards by folder ID
  Future<List<Map<String, dynamic>>> getCardsByFolderId(int folderId) async {
    final db = await database;
    return await db.query('Cards', where: 'folder_id = ?', whereArgs: [folderId]);
  }

  // Insert a new folder
  Future<int> insertFolder(Map<String, dynamic> folder) async {
    final db = await database;
    return await db.insert('Folders', folder);
  }

  // Insert a new card
  Future<int> insertCard(Map<String, dynamic> card) async {
    final db = await database;
    return await db.insert('Cards', card);
  }

  // Update a card
  Future<int> updateCard(Map<String, dynamic> card) async {
    final db = await database;
    return await db.update('Cards', card, where: 'id = ?', whereArgs: [card['id']]);
  }

  // Delete a card
  Future<int> deleteCard(int cardId) async {
    final db = await database;
    return await db.delete('Cards', where: 'id = ?', whereArgs: [cardId]);
  }

  // Delete a folder and all associated cards
  Future<int> deleteFolder(int folderId) async {
    final db = await database;
    await db.delete('Cards', where: 'folder_id = ?', whereArgs: [folderId]);
    return await db.delete('Folders', where: 'id = ?', whereArgs: [folderId]);
  }
}
