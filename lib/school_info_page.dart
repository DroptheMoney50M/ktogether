import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SchoolInfoPage extends StatelessWidget {
  const SchoolInfoPage({super.key});

  Widget _buildDocRow(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(fontSize: 15, color: Color(0xFF388E3C))),
          const Divider(height: 18, thickness: 1, color: Color(0xFFE0E0E0)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF0FFF4),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '경남정보대학교',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Image.asset(
                        'assets/kit_logo.png',
                        width: 70,
                        height: 70,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Busan, Sasang-gu, Jurye-ro 45',
                    style: TextStyle(fontSize: 18, color: Color(0xFF388E3C)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gerekli Belgeler',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDocRow('1) Başvuru Formu',
                              'Üniversitenin belirlediği formatta, Korece veya İngilizce doldurulup imzalanmalı'),
                          _buildDocRow('2) Özgeçmiş ve Eğitim Planı',
                              'Üniversitenin belirlediği formatta, Korece veya İngilizce doldurulup imzalanmalı'),
                          _buildDocRow(
                              '3) Lise Not Dökümü ve Mezuniyet (veya Beklenen Mezuniyet) Belgesi',
                              'Apostil veya konsolosluk onaylı belge'),
                          _buildDocRow('4) Yabancı Kimlik Kartı Fotokopisi',
                              'Sadece Kore’de ikamet edenler için'),
                          _buildDocRow(
                              '5) Adayın ve Ebeveynlerin Vatandaşlık ve Aile Bağını Gösteren Belgeler',
                              'Pasaport, doğum belgesi, aile nüfus kayıt örneği, kimlik kartı vb.'),
                          _buildDocRow(
                              '6) Korece Yeterlilik Sınavı (TOPIK) Belgesi',
                              'Sadece ilgili adaylar için'),
                          _buildDocRow('7) Mali Teminat Belgeleri',
                              'Üniversitenin belirlediği formatta, Korece veya İngilizce doldurulup imzalanmalı / Banka hesap dökümü vb. / Apostil veya konsolosluk onaylı belge'),
                          const SizedBox(height: 10),
                          const Text(
                              '※ Vatandaşlık ve başvuru programına göre belgeler değişebilir.',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF388E3C))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 유학 상담하기 버튼 (구글폼으로 이동)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Kişisel Verilerin Toplanması ve Kullanımı Onayı'),
                            content: const Text(
                              'Danışmanlık başvurusu için adınız, iletişim bilgileriniz gibi kişisel verileriniz toplanacaktır. Girdiğiniz bilgiler yalnızca danışmanlık amacıyla kullanılacak ve Google Form (harici hizmet) üzerinde saklanacaktır.\n\nDetaylı bilgi için lütfen Gizlilik Politikasını inceleyiniz.\n\nDevam etmek için onay veriniz.'
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Vazgeç'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: const Text('Onayla ve Devam Et'),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  const url = 'https://forms.gle/YcMrvfmoRWSfG4Qh6';
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Yurtdışı Eğitim Danışmanlığı',
                          style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF43A047),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}