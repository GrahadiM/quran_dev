import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quran_viewmodel.dart';
import 'detail_surah_screen.dart';

class PilihSuratScreen extends StatelessWidget {
  const PilihSuratScreen({super.key});

  final List<Map<String, String>> daftarSurat = const [
    {'no': '112', 'nama': 'Al-Ikhlas', 'file': '112-al-ikhlash.json'},
    {'no': '113', 'nama': 'Al-Falaq', 'file': '113-al-falaq.json'},
    {'no': '114', 'nama': 'An-Nas', 'file': '114-an-nas.json'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Surat (Juz 30)"),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: daftarSurat.length,
        itemBuilder: (context, index) {
          final surat = daftarSurat[index];
          return ListTile(
            leading: CircleAvatar(child: Text(surat['no']!)),
            title: Text(surat['nama']!),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.read<QuranViewModel>().loadSurahData(surat['file']!);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DetailSurahScreen()),
              );
            },
          );
        },
      ),
    );
  }
}
