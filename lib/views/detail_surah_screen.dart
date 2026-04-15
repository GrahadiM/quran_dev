import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quran_viewmodel.dart';

class DetailSurahScreen extends StatelessWidget {
  const DetailSurahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranVM = Provider.of<QuranViewModel>(context);

    if (quranVM.isLoading || quranVM.verses.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    final targetAyat = quranVM.currentAyat;

    return Scaffold(
      appBar: AppBar(
        title: Text("Ayat ${targetAyat.nomor}"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            quranVM.stopListening();
            quranVM.stopAllAudio();
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
                  // Teks Arab dengan Highlight per kata
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 12,
                    textDirection: TextDirection.rtl,
                    children: List.generate(targetAyat.segments.length, (
                      index,
                    ) {
                      final segment = targetAyat.segments[index];
                      final bool isActive = quranVM.activeWordIndex == index;

                      return GestureDetector(
                        onTap: () => quranVM.playWordAudio(segment, index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.yellow.withOpacity(0.5)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: isActive
                                ? Border.all(color: Colors.orange, width: 1)
                                : null,
                          ),
                          child: Text(
                            segment.word,
                            style: TextStyle(
                              fontSize: 32,
                              fontFamily:
                                  'Amiri', // Pastikan font terdaftar di pubspec
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? Colors.green.shade900
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    targetAyat.terjemahan,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tombol Putar Contoh Qori Full Ayat
                  ElevatedButton.icon(
                    onPressed: () => quranVM.playFullAudio(targetAyat),
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
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panel Kontrol Bawah
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  quranVM.correctionStatus,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Button Previous
                    IconButton(
                      onPressed: quranVM.currentIndex > 0
                          ? quranVM.previousAyat
                          : null,
                      icon: const Icon(Icons.skip_previous, size: 45),
                      color: Colors.green,
                      disabledColor: Colors.grey,
                    ),

                    // Button Mic (Hold to talk)
                    GestureDetector(
                      onLongPressStart: (_) =>
                          quranVM.startListening(targetAyat),
                      onLongPressEnd: (_) => quranVM.stopListening(),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: quranVM.isListening
                            ? Colors.red
                            : Colors.green,
                        child: Icon(
                          quranVM.isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),

                    // Button Next
                    IconButton(
                      onPressed:
                          quranVM.currentIndex < quranVM.verses.length - 1
                          ? quranVM.nextAyat
                          : null,
                      icon: const Icon(Icons.skip_next, size: 45),
                      color: Colors.green,
                      disabledColor: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
