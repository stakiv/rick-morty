import 'package:flutter/material.dart';
import 'package:my_app/models/characters_model.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const CharacterCard({
    super.key,
    required this.character,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(
              width: 2, color: Color.fromRGBO(0, 174, 208, 100))),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                character.image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15.0),
                Text(
                  character.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5.0),
                Text(
                  character.status,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: const Color.fromRGBO(116, 255, 69, 0.808),
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
