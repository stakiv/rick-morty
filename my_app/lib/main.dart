import 'package:flutter/material.dart';
import 'package:my_app/database/db.dart';
import 'package:my_app/models/api_service.dart';
import 'package:my_app/models/characters_repository.dart';
import 'package:my_app/models/database_service.dart';
import 'package:my_app/models/favs_provider.dart';
import 'package:my_app/my_nav_page.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

void main() {
  final dioInstance =
      Dio(BaseOptions(baseUrl: 'https://rickandmortyapi.com/api'));
  final dbInstance = DatabaseHelper.instance;

  runApp(MultiProvider(
    providers: [
      Provider<ApiService>(
        create: (_) => ApiService(dio: dioInstance, db: dbInstance),
      ),
      Provider<DatabaseService>(
        create: (_) => DatabaseService(db: dbInstance),
      ),
      Provider<CharactersRepository>(
        create: (context) => CharactersRepository(
          apiService: context.read<ApiService>(),
          databaseService: context.read<DatabaseService>(),
        ),
      ),
      ChangeNotifierProvider<FavsProvider>(
        create: (_) => FavsProvider()..loadFavs(),
      ),
    ],
    child: const MyApp(),
  )
      /*
    ChangeNotifierProvider(
    create: (context) => FavsProvider()..loadFavs(),
    child: const MyApp(),
  )*/
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: const MyNavigationPage(),
    );
  }
}
