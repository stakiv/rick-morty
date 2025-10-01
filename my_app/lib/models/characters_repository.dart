import 'package:logger/logger.dart';
import 'package:my_app/models/api_service.dart';
import 'package:my_app/models/database_service.dart';
import 'characters_model.dart';

class CharactersRepository {
  final ApiService apiService;
  final DatabaseService databaseService;
  final Logger _logger = Logger();

  CharactersRepository(
      {required this.apiService, required this.databaseService});

  Future<List<Character>> getCharacters({int page = 1}) async {
    try {
      final characters = await apiService.getCharacters(page: page);
      await databaseService.saveCharacters(characters);
      return characters;
    } catch (e) {
      _logger.i('loading characters from local db due to: $e');
      return await databaseService.getCharacters();
    }
  }
}
