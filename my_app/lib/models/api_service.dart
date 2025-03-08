import 'dart:async';
import 'package:dio/dio.dart';
import 'package:my_app/database/db.dart';
import 'characters_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://rickandmortyapi.com/api'));
//получение списка персонажей
  Future<List<Character>> getCharacters({int page = 1}) async {
    try {
      final response =
          await _dio.get('/character', queryParameters: {'page': page});
      if (response.statusCode == 200) {
        List<Character> characters = (response.data['results'] as List)
            .map((json) => Character.fromJson(json))
            .toList();
        final db = DatabaseHelper.instance;
        for (var c in characters) {
          await db.addCharacter(c);
        }
        return characters;
      } else {
        throw Exception('Failed to load characters');
      }
    } catch (e) {
      throw Exception('Error fetching characters: $e');
    }
  }
}
