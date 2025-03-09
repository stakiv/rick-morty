import 'package:my_app/models/characters_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

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

  // добавление персонажа
  Future<int> addCharacter(Character character) async {
    print('addCharacter func called, character.id=${character.id}');
    final db = await instance.database;
    return await db.insert('characters', character.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // добавление персонажа в избранное
  Future<int> addCharacterToFavs(int id) async {
    print('addCharacterToFavs func called, character.id=${id}');
    final db = await instance.database;
    final res = await db.insert('fav_characters', {'character_id': id},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    print('result: $res');
    return res;
  }

  // получене персонажей
  Future<List<Character>> getCharacters() async {
    print('getCharacters func called');
    final db = await instance.database;
    final res = await db.query('characters');
    print('все персонажи $res');
    return res.map((json) => Character.fromJson(json)).toList();
  }

  // получене избранных персонажей
  Future<List<Character>> getCharactersFav() async {
    print('getCharactersFav func called');
    final db = await instance.database;
    final q = await db.query('fav_characters');
    final ids = q.map((json) => json['character_id'] as int).toList();
    for (var id in ids) print(id);

    if (ids.isEmpty) return [];
    final res = await db.query('characters', where: 'id IN (${ids.join(',')})');
    //print('персонажи из избранного $res');
    return res.map((json) => Character.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getFavs() async {
    final db = await instance.database;
    final res = await db.query('fav_characters');
    print('fav_characters: $res');
    return res;
  }

  // удаление персонажа
  Future<int> removeCharacter(int id) async {
    print('removeCharacter func called, character.id=${id}');
    final db = await instance.database;
    return await db.delete('characters', where: 'id = ?', whereArgs: [id]);
  }

  // удаление персонажа из избранного
  Future<int> removeCharacterFromFavs(int id) async {
    print('removeCharacterFromFavs func called, character.id=${id}');
    final db = await instance.database;
    return await db
        .delete('fav_characters', where: 'character_id = ?', whereArgs: [id]);
  }
}
