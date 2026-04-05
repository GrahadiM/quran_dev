import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quran_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/quran_model.dart';

class DetailSurahScreen extends StatelessWidget {
  const DetailSurahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranVM = Provider.of<QuranViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);

    // Gunakan data dari model (ayat1Ikhlas sudah didefinisikan di quran_model.dart)
    final targetAyat = ayat1Ikhlas;

    return Scaffold(
      appBar: AppBar(
        title: Text("Surat Al-Ikhlas - ${authVM.currentClass ?? 'Demo'}"),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                targetAyat.teks,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri', // Pastikan font sudah terpasang
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
              const SizedBox(height: 50),

              // Widget Status Koreksi
              Container(
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text("Hasil Deteksi Suara: \"${quranVM.userSpeech}\""),
              const SizedBox(height: 50),

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
                style: TextStyle(
                  color: quranVM.isListening ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
