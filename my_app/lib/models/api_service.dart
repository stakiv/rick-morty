import 'dart:async';
import 'package:dio/dio.dart';
import 'package:my_app/database/db.dart';
import 'characters_model.dart';
import 'package:logger/logger.dart';

class ApiService {
  final Dio dio;
  // = Dio(BaseOptions(baseUrl: 'https://rickandmortyapi.com/api'));
  final DatabaseHelper db;
  final Logger _logger = Logger();

  ApiService({required this.dio, required this.db});
  // логирование информации
  void logInfo(String message) {
    _logger.i(message);
  }

//получение списка персонажей
  Future<List<Character>> getCharacters({int page = 1}) async {
    //final db = DatabaseHelper.instance;
    try {
      final response =
          await dio.get('/character', queryParameters: {'page': page});
      if (response.statusCode == 200) {
        List<Character> characters = (response.data['results'] as List)
            .map((json) => Character.fromJson(json))
            .toList();
        /*for (var c in characters) {
          await db.addCharacter(c);
        }*/
        return characters;
      } else {
        throw Exception('Failed to load characters');
      }
    } catch (e) {
      // если нет сети, загружаем сохраненные данные
      logInfo('load local data');
      rethrow;
      //return await db.getCharacters();
      //throw Exception('Error fetching characters: $e');
    }
  }
}
