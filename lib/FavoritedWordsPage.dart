import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritedWordsPage extends StatefulWidget {
  final List<Map<String, String>> favoritedWords;

  const FavoritedWordsPage({super.key, required this.favoritedWords});

  @override
  State<FavoritedWordsPage> createState() => _FavoritedWordsPageState();
}

class _FavoritedWordsPageState extends State<FavoritedWordsPage> {
  void _saveFavoritedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWords = widget.favoritedWords
        .map((word) => Uri(queryParameters: word).query)
        .toList();
    await prefs.setStringList('favoritedWords', savedWords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        title: const Text('Favori Kelimeler'),
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
      ),
      body: widget.favoritedWords.isEmpty
          ? const Center(
              child: Text(
                'Henüz favori kelime eklenmedi.',
                style: TextStyle(fontSize: 18, color: Color(0xFF388E3C)),
              ),
            )
          : ListView.builder(
              itemCount: widget.favoritedWords.length,
              itemBuilder: (context, index) {
                final word = widget.favoritedWords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(
                      word['korean'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    subtitle: Text(
                      word['turkish'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFd32f2f)),
                      onPressed: () {
                        setState(() {
                          widget.favoritedWords.removeAt(index);
                          _saveFavoritedWords();
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
