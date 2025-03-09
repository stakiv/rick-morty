import 'package:flutter/material.dart';
import 'package:my_app/components/character_item.dart';
import 'package:my_app/models/api_service.dart';
import '../models/characters_model.dart';
import 'package:provider/provider.dart';
import 'package:my_app/models/favs_provider.dart';

class MyMainPage extends StatefulWidget {
  const MyMainPage({super.key});

  @override
  State<MyMainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  List<Character> _characters = [];
  bool isLoading = false; // отображение загрузки
  bool checkMore = true; // есть ли дальше страницы
  int currPage = 1; // номер актуальной страницы

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getCharacters();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // получение персонажей
  Future<void> _getCharacters() async {
    if (isLoading || !checkMore) return;
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedCharacters =
          await ApiService().getCharacters(page: currPage);
      setState(() {
        _characters.addAll(fetchedCharacters);
        currPage++;
        checkMore = fetchedCharacters.isNotEmpty;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // подгрузка страницы если находимся внизу
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _getCharacters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Персонажи Рика и Морти',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification) {
              if (ScrollNotification is ScrollUpdateNotification &&
                  _scrollController.position.pixels ==
                      _scrollController.position.maxScrollExtent) {
                _getCharacters();
              }
              return false;
            },
            child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0),
                itemCount: _characters.length + (isLoading ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == _characters.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final character = _characters[index];
                  return CharacterCard(
                      character: character,
                      isFavorite: Provider.of<FavsProvider>(context)
                          .isFav(character.id),
                      onFavoriteToggle: () {
                        Provider.of<FavsProvider>(context, listen: false)
                            .toggleFavs(character);
                      });
                }),
          ),
        ));
  }
}
