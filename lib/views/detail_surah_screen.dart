import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quran_viewmodel.dart';

class DetailSurahScreen extends StatelessWidget {
  const DetailSurahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranVM = Provider.of<QuranViewModel>(context);

    if (quranVM.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final targetAyat = quranVM.currentAyat;

    return Scaffold(
      appBar: AppBar(
        title: Text("Ayat ${targetAyat.nomor}"),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            quranVM.stopListening();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  // Teks Arab
                  Text(
                    targetAyat.teks,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 20),

                  // Terjemahan
                  Text(
                    targetAyat.terjemahan,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // --- FITUR BARU: OUTPUT TEKS AUDIO (TRANSKRIPSI) ---
                  const Text(
                    "Suara Anda terdeteksi sebagai:",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      quranVM.userSpeech.isEmpty ||
                              quranVM.userSpeech == "Mendengarkan..."
                          ? "..."
                          : quranVM.userSpeech,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Amiri',
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  // ---------------------------------------------------
                  const SizedBox(height: 30),

                  // Status Koreksi (Auto Correct Output)
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: quranVM.correctionStatus.contains("MasyaAllah")
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: quranVM.correctionStatus.contains("MasyaAllah")
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    child: Text(
                      quranVM.correctionStatus,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls (Navigasi, Mic, Play)
          Container(
            padding: const EdgeInsets.only(
              bottom: 30,
              left: 20,
              right: 20,
              top: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Button Previous
                    IconButton(
                      onPressed: quranVM.currentIndex > 0
                          ? quranVM.previousAyat
                          : null,
                      icon: const Icon(Icons.skip_previous, size: 40),
                      color: Colors.green,
                    ),

                    // Tombol Mic (Hold to Speak)
                    GestureDetector(
                      onLongPressStart: (_) =>
                          quranVM.startCorrection(targetAyat),
                      onLongPressEnd: (_) => quranVM.stopListening(),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: quranVM.isListening
                                ? Colors.red
                                : Colors.green,
                            child: Icon(
                              quranVM.isListening ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            quranVM.isListening
                                ? "Lepas untuk Selesai"
                                : "Tahan untuk Bicara",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Button Next
                    IconButton(
                      onPressed:
                          quranVM.currentIndex < quranVM.verses.length - 1
                          ? quranVM.nextAyat
                          : null,
                      icon: const Icon(Icons.skip_next, size: 40),
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Button Play Example
                ElevatedButton.icon(
                  onPressed: () => quranVM.playExampleAudio(targetAyat),
                  icon: Icon(
                    quranVM.isPlaying
                        ? Icons.stop_circle
                        : Icons.play_circle_fill,
                  ),
                  label: Text(
                    quranVM.isPlaying ? "Berhenti" : "Putar Contoh Qori",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
