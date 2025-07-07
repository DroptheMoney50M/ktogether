import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart'; // 업그레이더 패키지 import
import 'package:shared_preferences/shared_preferences.dart';

import 'word_card_page.dart';
import 'school_info_page.dart';
import 'FavoritedWordsPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Korean Quiz for Turkish',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 업그레이더 적용: home을 UpgradeAlert로 감쌈
      home: UpgradeAlert(
        upgrader: Upgrader(
          messages: UpgraderMessages(code: 'tr'), // 터키어 메시지
        ),
        child: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<Map<String, String>> favoritedWords = [];

  @override
  void initState() {
    super.initState();
    _loadFavoritedWords();
  }

  void _loadFavoritedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWords = prefs.getStringList('favoritedWords') ?? [];
    setState(() {
      favoritedWords = savedWords
          .map((word) => Map<String, String>.from(
              Map<String, dynamic>.from(Uri.splitQueryString(word))))
          .toList();
    });
  }

  void _saveFavoritedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWords = favoritedWords
        .map((word) => Uri(queryParameters: word).query)
        .toList();
    await prefs.setStringList('favoritedWords', savedWords);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      WordCardPage(onFavorite: (word) {
        setState(() {
          favoritedWords.add(word);
          _saveFavoritedWords();
        });
      }),
      FavoritedWordsPage(favoritedWords: favoritedWords),
      SchoolInfoPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Kelime', // 단어 학습
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), 
            label: 'Favori Kelimeler', // 즐겨찾기 단어

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Yurtdışı Bilgi', // 유학 정보
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF2E7D32),
        unselectedItemColor: Color(0xFF81C784),
        backgroundColor: Color(0xFFF0FFF4),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}