import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../viewmodels/quran_viewmodel.dart';

class DetailSurahScreen extends StatelessWidget {
  const DetailSurahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranVM = Provider.of<QuranViewModel>(context);

    // Tampilan Loading jika data belum siap
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
                  // Status Skor
                  if (quranVM.accuracyScore > 0)
                    _buildScoreBadge(quranVM.accuracyScore),

                  const SizedBox(height: 20),

                  // Area Teks Arab
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(words.length, (index) {
                        Color wordColor = Colors.black87;
                        if (quranVM.successIndices.contains(index))
                          wordColor = Colors.green;
                        if (quranVM.errorIndices.contains(index))
                          wordColor = Colors.red;

                        return Text(
                          words[index],
                          style: const TextStyle(
                            fontSize: 38,
                            fontFamily: 'Amiri',
                            height: 2,
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 30),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: score > 80 ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: score > 80 ? Colors.green : Colors.orange),
      ),
      child: Text(
        "Akurasi: ${score.toStringAsFixed(0)}%",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: score > 80 ? Colors.green[900] : Colors.orange[900],
        ),
      ),
    );
  }

  Widget _buildControlPanel(
    BuildContext context,
    QuranViewModel quranVM,
    targetAyat,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            quranVM.correctionStatus,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () => quranVM.playExampleAudio(targetAyat),
            icon: Icon(quranVM.isPlaying ? Icons.stop : Icons.play_arrow),
            label: Text(quranVM.isPlaying ? "Berhenti" : "Dengarkan Qori"),
            style: ElevatedButton.styleFrom(
              backgroundColor: quranVM.isPlaying
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
                icon: const Icon(Icons.arrow_back_ios),
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
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget Animasi Waveform Sederhana
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
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(15, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: 10 + (Random().nextDouble() * 40 * _controller.value),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
