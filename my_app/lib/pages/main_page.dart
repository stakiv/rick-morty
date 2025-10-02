import 'package:flutter/material.dart';
import 'package:my_app/components/character_item.dart';
import 'package:my_app/models/api_service.dart';
import 'package:my_app/models/characters_repository.dart';
import '../models/characters_model.dart';
import 'package:provider/provider.dart';
import 'package:my_app/models/favs_provider.dart';
import 'package:logger/logger.dart';

class MyMainPage extends StatefulWidget {
  const MyMainPage({super.key});

  @override
  State<MyMainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  final List<Character> _characters = [];
  bool isLoading = false; // отображение загрузки
  bool checkMorePages = true; // есть ли дальше страницы
  int currPage = 1; // номер актуальной страницы
  final Logger _logger = Logger();

  final ScrollController _scrollController = ScrollController();

  late CharactersRepository charactersRepository;
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false);
    charactersRepository =
        Provider.of<CharactersRepository>(context, listen: false);
    _getCharacters();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // логирование информации
  void logInfo(String message) {
    _logger.i(message);
  }

  // получение персонажей
  Future<void> _getCharacters() async {
    if (isLoading || !checkMorePages) return;
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedCharacters =
          await charactersRepository.getCharacters(page: currPage);
      setState(() {
        _characters.addAll(fetchedCharacters);
        currPage++;
        checkMorePages = fetchedCharacters.isNotEmpty;
      });
    } catch (e) {
      logInfo('Error: $e');
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
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
          title: const Text('Персонажи Рика и Морти',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
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
