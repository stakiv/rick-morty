import 'package:my_app/database/db.dart';
import 'package:my_app/models/characters_model.dart';

class DatabaseService {
  final DatabaseHelper db;

  DatabaseService({required this.db});

  Future<void> saveCharacters(List<Character> characters) async {
    for (var c in characters) {
      await db.addCharacter(c);
    }
  }

  Future<List<Character>> getCharacters() async {
    return await db.getCharacters();
  }
}
