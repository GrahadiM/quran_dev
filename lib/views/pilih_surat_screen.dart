import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quran_viewmodel.dart';
import 'detail_surah_screen.dart';

class PilihSuratScreen extends StatefulWidget {
  const PilihSuratScreen({super.key});

  @override
  State<PilihSuratScreen> createState() => _PilihSuratScreenState();
}

class _PilihSuratScreenState extends State<PilihSuratScreen> {
  // Daftar surat asli
  final List<Map<String, String>> _allSurat = const [
    {'no': '112', 'nama': 'Al-Ikhlas', 'file': '112-al-ikhlash.json'},
    {'no': '113', 'nama': 'Al-Falaq', 'file': '113-al-falaq.json'},
    {'no': '114', 'nama': 'An-Nas', 'file': '114-an-nas.json'},
  ];

  // Daftar yang akan ditampilkan setelah filter
  List<Map<String, String>> _filteredSurat = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredSurat = _allSurat; // Inisialisasi awal menampilkan semua
  }

  void _filterSurat(String query) {
    setState(() {
      _filteredSurat = _allSurat
          .where(
            (surat) =>
                surat['nama']!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna sesuai tema Anda
    const Color textPrimary = Color(0xFF059212);
    const Color backgroundPrimary = Color(0xFF346739);
    const Color backgroundSecondary = Color(0xFFF3FF90);
    const Color textDefault = Color(0xFF020202);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Surat"),
        backgroundColor: backgroundPrimary,
      ),
      body: Column(
        children: [
          // Widget Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSurat,
              decoration: InputDecoration(
                hintText: "Cari nama surat...",
                prefixIcon: const Icon(Icons.search, color: textPrimary),
                filled: true,
                fillColor: backgroundSecondary.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Daftar Surat
          Expanded(
            child: _filteredSurat.isEmpty
                ? const Center(child: Text("Surat tidak ditemukan"))
                : ListView.builder(
                    itemCount: _filteredSurat.length,
                    itemBuilder: (context, index) {
                      final surat = _filteredSurat[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Card(
                          // Card secara otomatis menggunakan backgroundSecondary dari main.dart
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: textPrimary,
                              child: Text(
                                surat['no']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              surat['nama']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textDefault,
                              ),
                            ),
                            subtitle: const Text("Juz 30"),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: () {
                              context.read<QuranViewModel>().loadSurah(
                                surat['file']!,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DetailSurahScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
