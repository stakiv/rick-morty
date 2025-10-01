import 'package:flutter/material.dart';
import 'package:my_app/database/db.dart';
import 'package:my_app/models/characters_model.dart';

class FavsProvider with ChangeNotifier {
  List<Character> _favs = [];

  List<Character> get favourites => _favs;

  // загрузка избранных персонажей
  Future<void> loadFavs() async {
    final db = DatabaseHelper.instance;
    _favs = await db.getCharactersFav();
    notifyListeners();
  }

  // удаление или добавление персонажей в избранное
  Future<void> toggleFavs(Character character) async {
    final db = DatabaseHelper.instance;
    if (_favs.any((fav) => fav.id == character.id)) {
      await db.removeCharacterFromFavs(character.id);
      _favs.removeWhere((fav) => fav.id == character.id);
    } else {
      await db.addCharacterToFavs(character.id);
      _favs.add(character);
    }
    notifyListeners();
  }

  bool isFav(int id) {
    return _favs.any((c) => c.id == id);
  }

/*
  Future<void> addCharacterToFavs(int id) async {
    await DatabaseHelper.instance.addCharacterToFavs(id);
    await loadFavs();
  }

  Future<void> removeCharacterFromFavs(int id) async {
    await DatabaseHelper.instance.removeCharacterFromFavs(id);
    await loadFavs();
  }*/
}
