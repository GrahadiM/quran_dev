import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
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
    final words = targetAyat.teks.split(' ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Ayat ${targetAyat.nomor}"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  if (quranVM.accuracyScore > 0)
                    _buildScoreBadge(quranVM.accuracyScore),
                  const SizedBox(height: 20),

                  // Teks Arab dengan Feedback Warna & Tombol Play per Kata
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 15,
                      runSpacing: 30,
                      children: List.generate(words.length, (index) {
                        Color wordColor = Colors.black87;
                        if (quranVM.successIndices.contains(index))
                          wordColor = Colors.green;
                        if (quranVM.errorIndices.contains(index))
                          wordColor = Colors.red;

                        bool isWordPlaying = quranVM.activeWordIndex == index;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              words[index],
                              style: TextStyle(
                                fontSize: 38,
                                fontFamily: 'Amiri',
                                color: wordColor,
                                fontWeight: isWordPlaying
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            // Perbaikan EdgeInsets: Menggunakan .only(top: 5)
                            GestureDetector(
                              onTap: () => quranVM.playWordAudio(index),
                              child: Container(
                                margin: const EdgeInsets.only(top: 5),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isWordPlaying
                                      ? Colors.green
                                      : Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isWordPlaying ? Icons.stop : Icons.volume_up,
                                  size: 14,
                                  color: isWordPlaying
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Text(
                    targetAyat.terjemahan,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (quranVM.isListening) const WaveformAnimation(),
          _buildControlPanel(context, quranVM, targetAyat),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(double score) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300, width: 2),
        image: DecorationImage(
          image: NetworkImage(
            'https://www.transparenttextures.com/patterns/islamic-art.png',
          ), // Opsional: Pattern halus
          opacity: 0.1,
        ),
      ),
      child: Column(
        children: [
          Text(
            "SKOR TAJWID & KELANCARAN",
            style: TextStyle(
              color: Colors.amber.shade900,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${score.toStringAsFixed(0)}%",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          Text(
            score > 80 ? "MasyaAllah!" : "Terus Berlatih!",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(
    BuildContext context,
    QuranViewModel quranVM,
    dynamic targetAyat,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            quranVM.correctionStatus,
            style: TextStyle(
              color: quranVM.isListening ? Colors.red : Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () => quranVM.playExampleAudio(targetAyat),
            icon: Icon(
              quranVM.isPlaying && quranVM.activeWordIndex == null
                  ? Icons.stop
                  : Icons.play_arrow,
            ),
            label: Text(
              quranVM.isPlaying && quranVM.activeWordIndex == null
                  ? "Berhenti"
                  : "Dengarkan Qori Full",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  quranVM.isPlaying && quranVM.activeWordIndex == null
                  ? Colors.red
                  : Colors.blueGrey[800],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: quranVM.previousAyat,
                icon: const Icon(Icons.arrow_back_ios_rounded),
              ),
              GestureDetector(
                onLongPressStart: (_) => quranVM.startListening(targetAyat),
                onLongPressEnd: (_) => quranVM.stopListening(),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: quranVM.isListening
                      ? Colors.red
                      : Colors.green,
                  child: const Icon(Icons.mic, color: Colors.white, size: 35),
                ),
              ),
              IconButton(
                onPressed: quranVM.nextAyat,
                icon: const Icon(Icons.arrow_forward_ios_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WaveformAnimation extends StatefulWidget {
  const WaveformAnimation({super.key});
  @override
  State<WaveformAnimation> createState() => _WaveformAnimationState();
}

class _WaveformAnimationState extends State<WaveformAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(15, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 4,
              height:
                  10 + (Random(index).nextDouble() * 40 * _controller.value),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        }),
      ),
    );
  }
}
