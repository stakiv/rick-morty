import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/models/favs_provider.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  late Future<void> _favsFuture;

  @override
  void initState() {
    super.initState();
    _favsFuture = Provider.of<FavsProvider>(context, listen: false).loadFavs();
  }

  @override
  Widget build(BuildContext context) {
    final favourites = Provider.of<FavsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Избранные персонажи'),
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
              child: Text('Нет избранных персонажей'),
            );
          }

          return ListView.builder(
            itemCount: favourites.favourites.length,
            itemBuilder: (context, index) {
              final character = favourites.favourites[index];
              return Card(
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        favourites.toggleFavs(character);
                      },
                      icon: Icon(Icons.star_border),
                    ),
                    ClipRRect(
                      child: Image.network(
                        character.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          Text(
                            character.name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            character.status,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
