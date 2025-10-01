import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/models/favs_provider.dart';
import '../models/characters_model.dart';
import 'package:my_app/components/character_item.dart';
import 'package:logger/logger.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  late Future<void> _favsFuture;
  List<Character> _sortedFavs = [];
  String selectedSort = 'По умолчанию';
  final Logger _logger = Logger();

  // логирование информации
  void logInfo(String message) {
    _logger.i(message);
  }

  @override
  void initState() {
    super.initState();
    final favourites = Provider.of<FavsProvider>(context, listen: false);
    _sortedFavs = List.from(favourites.favourites);
    _favsFuture = favourites.loadFavs();
  }

  void _openSort() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          title: const Center(
            child: Text(
              'Сортировка',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: ['По умолчанию', 'По алфавиту'].map((sort) {
                    return RadioListTile<String>(
                      title: Text(
                        sort,
                        style: const TextStyle(fontSize: 14),
                      ),
                      value: sort,
                      groupValue: selectedSort,
                      onChanged: (String? value) {
                        setState(() {
                          if (value != null) {
                            selectedSort = value;
                          }

                          logInfo(selectedSort);
                        });
                      },
                      activeColor: const Color.fromRGBO(0, 174, 208, 100),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Закрыть',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(102, 201, 221, 0.612))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sortCharacters(selectedSort);

                logInfo(selectedSort);
              },
              child: const Text('Применить',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(0, 174, 208, 100))),
            ),
          ],
        );
      },
    );
  }

  void _sortCharacters(String sortOpt) {
    final favourites =
        Provider.of<FavsProvider>(context, listen: false).favourites;
    setState(() {
      _sortedFavs = List.from(favourites);
      if (selectedSort == 'По алфавиту') {
        _sortedFavs.sort((a, b) => a.name.compareTo(b.name));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favourites = Provider.of<FavsProvider>(context);
    if (_sortedFavs.isEmpty ||
        _sortedFavs.length != favourites.favourites.length) {
      _sortedFavs = List.from(favourites.favourites);
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        title: const Text(
          'Избранные персонажи',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
              onPressed: _openSort,
              icon: const Icon(
                Icons.sort,
                color: Color.fromRGBO(0, 174, 208, 100),
              ))
        ],
      ),
      body: FutureBuilder(
        future: _favsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (favourites.favourites.isEmpty) {
            return const Center(
              child: Text('Нет избранных персонажей',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0),
                itemCount: _sortedFavs.length,
                itemBuilder: (BuildContext context, int index) {
                  final character = _sortedFavs[index];
                  return CharacterCard(
                      character: character,
                      isFavorite: favourites.isFav(character.id),
                      onFavoriteToggle: () {
                        Provider.of<FavsProvider>(context, listen: false)
                            .toggleFavs(character);
                        _sortedFavs;
                      });
                }),
          );
        },
      ),
    );
  }
}
