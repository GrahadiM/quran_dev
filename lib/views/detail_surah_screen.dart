import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quran_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class DetailSurahScreen extends StatelessWidget {
  const DetailSurahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranVM = Provider.of<QuranViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);

    if (quranVM.verses.isEmpty) {
      if (!quranVM.isLoading) quranVM.loadSurahData();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Ambil ayat berdasarkan indeks aktif
    final targetAyat = quranVM.currentAyat;

    return Scaffold(
      appBar: AppBar(
        title: Text("Al-Ikhlas: Ayat ${targetAyat.nomor}"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Info Kelas
              Text(
                "Kelas: ${authVM.currentClass ?? 'Umum'}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Teks Arab
              Text(
                targetAyat.teks,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              Text(
                targetAyat.terjemahan,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Audio & Navigasi Ayat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: quranVM.currentIndex > 0
                        ? () => quranVM.previousAyat()
                        : null,
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.green,
                  ),
                  TextButton.icon(
                    onPressed: () => quranVM.playExampleAudio(targetAyat),
                    icon: const Icon(Icons.volume_up),
                    label: const Text("Contoh"),
                  ),
                  IconButton(
                    onPressed: quranVM.currentIndex < quranVM.verses.length - 1
                        ? () => quranVM.nextAyat()
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status Koreksi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: quranVM.correctionStatus.contains("MasyaAllah")
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  quranVM.correctionStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "Suara Anda: \"${quranVM.userSpeech}\"",
                style: const TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 40),

              // Tombol Mic
              GestureDetector(
                onLongPressStart: (_) => quranVM.startCorrection(targetAyat),
                onLongPressEnd: (_) => quranVM.stopListening(),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: quranVM.isListening
                      ? Colors.red
                      : Colors.green,
                  child: Icon(
                    quranVM.isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                quranVM.isListening
                    ? "Lepas untuk selesai"
                    : "Tahan untuk merekam",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
