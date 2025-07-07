import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class WordCardPage extends StatefulWidget {
  final Function(Map<String, String>) onFavorite;

  const WordCardPage({super.key, required this.onFavorite});

  @override
  State<WordCardPage> createState() => _WordCardPageState();
}

class _WordCardPageState extends State<WordCardPage> {
  List<List<dynamic>> allWords = [];
  List<List<dynamic>> words = [];
  List<String> categories = ['Tümü'];
  String selectedCategory = 'Tümü';
  int current = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool loading = true;
  List<Map<String, String>> favoritedWords = [];

  @override
  void initState() {
    super.initState();
    print('initState: 앱 시작');
    fetchWords();
  }

  Future<void> fetchWords() async {
    print('fetchWords: 데이터 요청 시작');
    final url =
        'https://docs.google.com/spreadsheets/d/1n_fTqnQqylb8DAenIZV12lWAIZ0bRdT4Xk70VTvlXr0/gviz/tq?tqx=out:csv&sheet=sheet1';
    final response = await http.get(Uri.parse(url));
    print('fetchWords: 응답 statusCode = \\${response.statusCode}');
    if (response.statusCode == 200) {
      print(
          'fetchWords: 응답 body 일부 = \\${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}');
      // 줄바꿈 문제 해결을 위해 eol 명시
      final csvTable = CsvToListConverter(eol: '\n').convert(response.body);
      List<List<dynamic>> dataTable = csvTable;
      if (csvTable.length <= 1) {
        print('csvTable 길이가 1: eol을 \r\n으로 재시도');
        final csvTable2 =
            CsvToListConverter(eol: '\r\n').convert(response.body);
        print('csvTable2 길이 = \\${csvTable2.length}');
        if (csvTable2.length > 1) {
          dataTable = csvTable2;
        }
      }
      print('fetchWords: 파싱된 dataTable 길이 = \\${dataTable.length}');
      if (dataTable.length > 1) {
        // 헤더를 제외한 데이터만 섞기
        final header = dataTable.first;
        final data = List<List<dynamic>>.from(dataTable.skip(1));
        data.shuffle(Random());
        // 카테고리 추출
        final cats = data
            .map((row) => row.length > 4 ? row[4].toString() : '')
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();
        cats.sort();
        if (!mounted) return;
        setState(() {
          allWords = [header, ...data];
          categories = ['Tümü', ...cats];
          selectedCategory = 'Tümü';
          words = [header, ...data];
          loading = false;
          current = 0;
        });
        print('fetchWords: setState 후 words.length = \\${words.length} (셔플됨)');
      } else {
        if (!mounted) return;
        setState(() {
          allWords = dataTable;
          words = dataTable;
          loading = false;
        });
        print('fetchWords: setState 후 words.length = \\${words.length}');
      }
    } else {
      print('fetchWords: 에러 발생!');
    }
  }

  void filterByCategory(String category) {
    if (category == 'Tümü') {
      setState(() {
        words = List<List<dynamic>>.from(allWords);
        current = 0;
        selectedCategory = category;
      });
    } else {
      final header = allWords.first;
      final filtered = allWords
          .skip(1)
          .where((row) => row.length > 4 && row[4] == category)
          .toList();
      setState(() {
        words = [header, ...filtered];
        current = 0;
        selectedCategory = category;
      });
    }
  }

  void _nextWord() {
    print('_nextWord: 다음 단어로 이동 (current: \\${current})');
    setState(() {
      current = (current + 1) % (words.length - 1);
    });
    print('_nextWord: 이동 후 current = \\${current}');
  }

  void _speak() async {
    print('_speak: 발음 듣기 버튼 클릭');
    if (words.length > 1) {
      print('_speak: 읽을 단어 = \\${words[current + 1][1]}');
      await flutterTts.setLanguage('ko-KR');
      await flutterTts.speak(words[current + 1][1].toString());
    }
  }

  Widget _pronunciationRow(List<dynamic> word) {
    // 4번째 열(발음)이 있으면 예쁘게 보여줌
    if (word.length > 3 && word[3].toString().trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF3E3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.record_voice_over,
                  color: Color(0xFFff9800), size: 22),
              const SizedBox(width: 8),
              Text(
                word[3].toString(),
                style: const TextStyle(
                  fontSize: 19,
                  color: Color(0xFFff9800),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _exampleSentenceRow(List<dynamic> word) {
    // 5번째 열(카테고리 다음, 인덱스 5)에 예문이 있는지 확인
    if (word.length > 5 && word[5].toString().trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8E9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_quote,
                      color: Color(0xFF66BB6A), size: 18),
                  const SizedBox(width: 4),
                  const Text(
                    '예문', // 한국어로 예문
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF66BB6A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                word[5].toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF33691E),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'build: loading=\\$loading, words.length=\\${words.length}, current=\\$current');
    if (loading || words.length < 2) {
      print('build: 로딩 중 또는 데이터 부족');
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // 첫 행은 헤더이므로, 실제 데이터는 words[current+1]
    final word = words[current + 1];
    print('build: 현재 단어 = \\${word}');
    // word: [id, 한국어_단어, 터키어_의미, 발음, 카테고리, 예문]
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 좌우 스크롤 카테고리 위에 화살표 추가
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.arrow_left, color: Color(0xFF388E3C), size: 24),
                    Text(
                        'Kategori (Sağa sola kaydırabilirsiniz)',
                      style: TextStyle(

                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                    Icon(Icons.arrow_right, color: Color(0xFF388E3C), size: 24),
                  ],

                ),
                
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, idx) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = categories[idx];
                    final selected = selectedCategory == cat;
                    // 카테고리별 아이콘 매핑
                    IconData? icon;
                    switch (cat) {
                      case 'Tümü':
                        icon = Icons.all_inclusive;
                        break;
                      case 'Eğitim':
                        icon = Icons.school;
                        break;
                      case 'Nesne':
                        icon = Icons.category;
                        break;
                      case 'Giyim':
                        icon = Icons.checkroom;
                        break;
                      case 'Yiyecek':
                        icon = Icons.restaurant;
                        break;
                      case 'Meyve':
                        icon = Icons.apple;
                        break;
                      case 'Mekan':
                        icon = Icons.location_city;
                        break;
                      case 'Mobilya':
                        icon = Icons.chair;
                        break;
                      case 'Elektronik':
                        icon = Icons.devices_other;
                        break;
                      case 'Aile':
                        icon = Icons.family_restroom;
                        break;
                      case 'İnsan':
                        icon = Icons.person;
                        break;
                      case 'Duygu':
                        icon = Icons.emoji_emotions;
                        break;
                      case 'Sanat':
                        icon = Icons.palette;
                        break;
                      case 'Seyahat':
                        icon = Icons.flight_takeoff;
                        break;
                      case 'Ulaşım':
                        icon = Icons.directions_bus;
                        break;
                      case 'Alışveriş':
                        icon = Icons.shopping_cart;
                        break;
                      case 'Kurum':
                        icon = Icons.account_balance;
                        break;
                      case 'Ekonomi':
                        icon = Icons.attach_money;
                        break;
                      case 'İletişim':
                        icon = Icons.phone;
                        break;
                      case 'Özel Gün':
                        icon = Icons.cake;
                        break;
                      case 'Zaman':
                        icon = Icons.access_time;
                        break;
                      case 'Diğer':
                        icon = Icons.more_horiz;
                        break;
                      case 'Doğa':
                        icon = Icons.park;
                        break;
                      case 'Hayvan':
                        icon = Icons.pets;
                        break;
                      case 'Yaşam':
                        icon = Icons.self_improvement;
                        break;
                      case 'Kırtasiye':
                        icon = Icons.edit;
                        break;
                      case 'Sıfat':
                        icon = Icons.text_fields;
                        break;
                      case 'Renk':
                        icon = Icons.color_lens;
                        break;
                      case 'Hava Durumu':
                        icon = Icons.wb_sunny;
                        break;
                      case 'Mevsim':
                        icon = Icons.thermostat;
                        break;
                      case 'Yer Adı':
                        icon = Icons.place;
                        break;
                      case 'Uzay':
                        icon = Icons.public;
                        break;
                      case 'Spor':
                        icon = Icons.sports_soccer;
                        break;
                      case 'Günlük Yaşam':
                        icon = Icons.home;
                        break;
                      case 'Geometrik Şekil':
                        icon = Icons.crop_square;
                        break;
                      case 'Vücut':
                        icon = Icons.accessibility_new;
                        break;
                      case 'Mutfak':
                        icon = Icons.kitchen;
                        break;
                      case 'Akademik':
                        icon = Icons.menu_book;
                        break;
                      case 'Gün':
                        icon = Icons.today;
                        break;
                      case 'Zarf':
                        icon = Icons.swap_horiz;
                        break;
                      case 'Bağlaç':
                        icon = Icons.link;
                        break;
                      case 'Sağlık':
                        icon = Icons.local_hospital;
                        break;
                      case 'Ev İşi':
                        icon = Icons.cleaning_services;
                        break;
                      case 'Mağaza':
                        icon = Icons.store;
                        break;
                      case 'Malzeme':
                        icon = Icons.widgets;
                        break;
                      case 'ev':
                        icon = Icons.house;
                        break;
                      case 'Hizmet':
                        icon = Icons.room_service;
                        break;
                      case 'IT':
                        icon = Icons.computer;
                        break;
                      case 'Ülke':
                        icon = Icons.flag;
                        break;
                      case 'moda':
                        icon = Icons.style;
                        break;
                      case 'Okul':
                        icon = Icons.apartment;
                        break;
                      case 'Meslek':
                        icon = Icons.work;
                        break;
                      case 'Öğrenci':
                        icon = Icons.school_outlined;
                        break;
                      case 'Eylem':
                        icon = Icons.directions_run;
                        break;
                      default:
                        icon = Icons.label_outline;
                    }
                    return GestureDetector(
                      onTap: () => filterByCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF43A047)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF388E3C)
                                : const Color(0xFFB2DFDB),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon,
                                size: 20,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF388E3C)),
                            const SizedBox(width: 6),
                            Text(
                              cat,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF388E3C),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                color: Colors.white,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 카테고리별 대표 아이콘
                      Builder(
                        builder: (context) {
                          // 현재 단어의 카테고리 추출
                          String? category;
                          if (word.length > 4) {
                            category = word[4]?.toString();
                          }
                          IconData icon;
                          Color iconColor = const Color(0xFF43A047);
                          switch (category) {
                            case 'Tümü':
                              icon = Icons.all_inclusive;
                              break;
                            case 'Eğitim':
                              icon = Icons.school;
                              break;
                            case 'Nesne':
                              icon = Icons.category;
                              break;
                            case 'Giyim':
                              icon = Icons.checkroom;
                              break;
                            case 'Yiyecek':
                              icon = Icons.restaurant;
                              break;
                            case 'Meyve':
                              icon = Icons.apple;
                              break;
                            case 'Mekan':
                              icon = Icons.location_city;
                              break;
                            case 'Mobilya':
                              icon = Icons.chair;
                              break;
                            case 'Elektronik':
                              icon = Icons.devices_other;
                              break;
                            case 'Aile':
                              icon = Icons.family_restroom;
                              break;
                            case 'İnsan':
                              icon = Icons.person;
                              break;
                            case 'Duygu':
                              icon = Icons.emoji_emotions;
                              break;
                            case 'Sanat':
                              icon = Icons.palette;
                              break;
                            case 'Seyahat':
                              icon = Icons.flight_takeoff;
                              break;
                            case 'Ulaşım':
                              icon = Icons.directions_bus;
                              break;
                            case 'Alışveriş':
                              icon = Icons.shopping_cart;
                              break;
                            case 'Kurum':
                              icon = Icons.account_balance;
                              break;
                            case 'Ekonomi':
                              icon = Icons.attach_money;
                              break;
                            case 'İletişim':
                              icon = Icons.phone;
                              break;
                            case 'Özel Gün':
                              icon = Icons.cake;
                              break;
                            case 'Zaman':
                              icon = Icons.access_time;
                              break;
                            case 'Diğer':
                              icon = Icons.more_horiz;
                              break;
                            case 'Doğa':
                              icon = Icons.park;
                              break;
                            case 'Hayvan':
                              icon = Icons.pets;
                              break;
                            case 'Yaşam':
                              icon = Icons.self_improvement;
                              break;
                            case 'Kırtasiye':
                              icon = Icons.edit;
                              break;
                            case 'Sıfat':
                              icon = Icons.text_fields;
                              break;
                            case 'Renk':
                              icon = Icons.color_lens;
                              break;
                            case 'Hava Durumu':
                              icon = Icons.wb_sunny;
                              break;
                            case 'Mevsim':
                              icon = Icons.thermostat;
                              break;
                            case 'Yer Adı':
                              icon = Icons.place;
                              break;
                            case 'Uzay':
                              icon = Icons.public;
                              break;
                            case 'Spor':
                              icon = Icons.sports_soccer;
                              break;
                            case 'Günlük Yaşam':
                              icon = Icons.home;
                              break;
                            case 'Geometrik Şekil':
                              icon = Icons.crop_square;
                              break;
                            case 'Vücut':
                              icon = Icons.accessibility_new;
                              break;
                            case 'Mutfak':
                              icon = Icons.kitchen;
                              break;
                            case 'Akademik':
                              icon = Icons.menu_book;
                              break;
                            case 'Gün':
                              icon = Icons.today;
                              break;
                            case 'Zarf':
                              icon = Icons.swap_horiz;
                              break;
                            case 'Bağlaç':
                              icon = Icons.link;
                              break;
                            case 'Sağlık':
                              icon = Icons.local_hospital;
                              break;
                            case 'Ev İşi':
                              icon = Icons.cleaning_services;
                              break;
                            case 'Mağaza':
                              icon = Icons.store;
                              break;
                            case 'Malzeme':
                              icon = Icons.widgets;
                              break;
                            case 'ev':
                              icon = Icons.house;
                              break;
                            case 'Hizmet':
                              icon = Icons.room_service;
                              break;
                            case 'IT':
                              icon = Icons.computer;
                              break;
                            case 'Ülke':
                              icon = Icons.flag;
                              break;
                            case 'moda':
                              icon = Icons.style;
                              break;
                            case 'Okul':
                              icon = Icons.apartment;
                              break;
                            case 'Meslek':
                              icon = Icons.work;
                              break;
                            case 'Öğrenci':
                              icon = Icons.school_outlined;
                              break;
                            case 'Eylem':
                              icon = Icons.directions_run;
                              break;
                            default:
                              icon = Icons.eco;
                              break;
                          }
                          return Icon(icon, size: 48, color: iconColor);
                        },
                      ),
                      const SizedBox(height: 18),
                      // 한국어 단어
                      Text(
                        word[1].toString(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          letterSpacing: 2,
                        ),
                      ),
                      // 발음(로마자) 표시
                      _pronunciationRow(word),
                      const SizedBox(height: 12),

                      // 예문 - 예문이 있을 경우 표시
                      _exampleSentenceRow(word),

                      // 터키어 뜻
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 18),
                        decoration: BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          word[2].toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFF388E3C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 발음 듣기 버튼
                      ElevatedButton.icon(
                        onPressed: _speak,
                        icon: const Icon(Icons.volume_up_rounded,
                            color: Color(0xFF43A047)),
                        label:
                            const Text('Dinle', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC8E6C9),
                          foregroundColor: Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          elevation: 2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // 즐겨찾기 버튼
                      ElevatedButton.icon(
                        onPressed: () {
                          final word = words[current + 1];
                          widget.onFavorite({
                            'korean': word[1].toString(),
                            'turkish': word[2].toString(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kelime favorilere eklendi!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.favorite, color: Color(0xFFd32f2f)),
                        label: const Text('Favorilere Ekle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF8BBD0),
                          foregroundColor: Color(0xFFd32f2f),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          elevation: 2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // 다음 버튼
                      OutlinedButton(
                        onPressed: _nextWord,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF43A047), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: const Text(
                          'Sonraki',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF43A047),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 인덱스 표시
                      Text(
                        '${(current + 1).toString()} / ${words.length - 1}',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF81C784)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}