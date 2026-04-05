import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/quran_model.dart';

class QuranViewModel extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _userSpeech = "";
  String _correctionStatus = "Tekan & Tahan untuk mengaji...";
  double _startMicTime = 0;

  bool get isListening => _isListening;
  String get userSpeech => _userSpeech;
  String get correctionStatus => _correctionStatus;

  // Fungsi untuk menghapus Harakat agar bisa dibandingkan dengan hasil Speech
  String _removeDiacritics(String text) {
    var exp = RegExp(r'[\u064B-\u0652\u06D6-\u06ED]');
    return text.replaceAll(exp, '');
  }

  void startCorrection(Ayat ayat) async {
    // Pastikan inisialisasi berhasil
    bool available = await _speech.initialize(
      onError: (val) => print('Error Speech: $val'),
      onStatus: (val) => print('Status Speech: $val'),
    );

    if (available) {
      print("Mikrofon Tersedia");
      _isListening = true;
      _userSpeech = "Mendengarkan...";
      _startMicTime = DateTime.now().millisecondsSinceEpoch / 1000;
      notifyListeners();

      _speech.listen(
        localeId: 'ar-SA', // WAJIB Arab Saudi
        onResult: (result) {
          _userSpeech = result.recognizedWords;

          // Jika deteksi suara selesai (user berhenti bicara)
          if (result.finalResult) {
            _analyzeReading(ayat);
          }
          notifyListeners();
        },
      );
    } else {
      print("Mikrofon Tidak Tersedia");
      _correctionStatus = "Mikrofon tidak tersedia/izin ditolak.";
      notifyListeners();
    }
  }

  void _analyzeReading(Ayat target) {
    _isListening = false;
    double endTime = DateTime.now().millisecondsSinceEpoch / 1000;
    double userDuration = endTime - _startMicTime;

    // 1. Normalisasi: Hapus harakat dari teks Al-Qur'an asli
    String cleanTarget = _removeDiacritics(target.teks).trim();
    String cleanUser = _userSpeech.trim();

    // 2. Bandingkan Teks (Lafal)
    bool isMatch =
        cleanUser.contains(cleanTarget) || cleanTarget.contains(cleanUser);

    if (isMatch && cleanUser.isNotEmpty) {
      // 3. Bandingkan Durasi (Tajwid/Panjang Pendek)
      // Jika durasi user jauh lebih singkat dari durasi ideal Qori
      if (userDuration < (target.durasiIdeal * 0.7)) {
        _correctionStatus =
            "Lafal Benar, tapi terlalu cepat. Perhatikan panjang pendeknya (Mad).";
      } else {
        _correctionStatus = "MasyaAllah! Bacaan & Tajwid Anda Bagus.";
      }
    } else {
      _correctionStatus =
          "Bacaan kurang tepat. Coba perhatikan makhraj hurufnya.";
    }
    notifyListeners();
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }
}
