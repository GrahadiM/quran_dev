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
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: daftarSurat.length,
        itemBuilder: (context, index) {
          final surat = daftarSurat[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(
                surat['no']!,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              surat['nama']!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text("Juz 30"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Reset state dan muat data surat baru
              final quranVM = context.read<QuranViewModel>();
              quranVM.loadSurahData(surat['file']!);

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
