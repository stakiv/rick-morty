import 'package:my_app/models/characters_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final Logger _logger = Logger();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // удаляем бд каждый раз при запуске (на время тестирования)
    /*final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'characters.db');
    await deleteDatabase(path);*/

    _database = await _initDB('characters.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int ver) async {
    await db.execute('''
CREATE TABLE characters(
    id INTEGER PRIMARY KEY,
    name TEXT,
    status TEXT,
    species TEXT,
    image TEXT,
    location TEXT)''');
    await db.execute('''
CREATE TABLE fav_characters(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER UNIQUE)
    ''');
  }

  // логирование информации
  void logInfo(String message) {
    _logger.i(message);
  }

  // добавление персонажа
  Future<int> addCharacter(Character character) async {
    logInfo('addCharacter func called, character.id=${character.id}');
    final db = await instance.database;
    return await db.insert('characters', character.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // добавление персонажа в избранное
  Future<int> addCharacterToFavs(int id) async {
    logInfo('addCharacterToFavs func called, character.id=$id');
    final db = await instance.database;
    final res = await db.insert('fav_characters', {'character_id': id},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    logInfo('result: $res');
    return res;
  }

  // получене персонажей
  Future<List<Character>> getCharacters() async {
    logInfo('getCharacters func called');
    final db = await instance.database;
    final res = await db.query('characters');
    logInfo('все персонажи $res');
    return res.map((json) => Character.fromJson(json)).toList();
  }

  // получене избранных персонажей
  Future<List<Character>> getCharactersFav() async {
    logInfo('getCharactersFav func called');
    final db = await instance.database;
    final q = await db.query('fav_characters');
    final ids = q.map((json) => json['character_id'] as int).toList();
    for (var id in ids) {
      logInfo('$id');
    }

    if (ids.isEmpty) return [];
    final res = await db.query('characters', where: 'id IN (${ids.join(',')})');
    logInfo('персонажи из избранного $res');
    return res.map((json) => Character.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getFavs() async {
    final db = await instance.database;
    final res = await db.query('fav_characters');
    logInfo('fav_characters: $res');
    return res;
  }

  // удаление персонажа
  Future<int> removeCharacter(int id) async {
    logInfo('removeCharacter func called, character.id=$id');
    final db = await instance.database;
    return await db.delete('characters', where: 'id = ?', whereArgs: [id]);
  }

  // удаление персонажа из избранного
  Future<int> removeCharacterFromFavs(int id) async {
    logInfo('removeCharacterFromFavs func called, character.id=$id');
    final db = await instance.database;
    return await db
        .delete('fav_characters', where: 'character_id = ?', whereArgs: [id]);
  }
}
