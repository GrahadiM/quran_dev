import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quran_model.dart';

class QuranViewModel extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _audioTimer;

  List<Ayat> _verses = [];
  int _currentIndex = 0;
  bool _isListening = false;
  String _userSpeech = "";
  String _correctionStatus = "Tekan & Tahan untuk mengaji...";
  double _startMicTime = 0;
  bool _isLoading = false;

  List<Ayat> get verses => _verses;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String get userSpeech => _userSpeech;
  String get correctionStatus => _correctionStatus;

  Ayat get currentAyat => _verses[_currentIndex];

  Future<void> loadSurahData() async {
    if (_verses.isNotEmpty || _isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString(
        'assets/data/surah_ikhlas.json',
      );
      final data = json.decode(response);
      var list = data['verses'] as List;
      _verses = list.map((i) => Ayat.fromJson(i)).toList();
    } catch (e) {
      print("Error Loading JSON: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void nextAyat() {
    if (_currentIndex < _verses.length - 1) {
      _currentIndex++;
      _resetState();
      notifyListeners();
    }
  }

  void previousAyat() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _resetState();
      notifyListeners();
    }
  }

  void _resetState() {
    _audioTimer?.cancel();
    _audioPlayer.stop();
    _userSpeech = "";
    _correctionStatus = "Tekan & Tahan untuk mengaji...";
  }

  void _stopAudio() {
    _audioTimer?.cancel();
    _audioPlayer.stop();
  }

  // --- PERBAIKAN FUNGSI AUDIO ---
  void playExampleAudio(Ayat ayat) async {
    try {
      // 1. Hentikan audio dan timer yang sedang berjalan
      _audioTimer?.cancel();
      await _audioPlayer.stop();

      // 2. Set source terlebih dahulu
      await _audioPlayer.setSource(AssetSource(ayat.audioPath));

      // 3. KRITIKAL: Seek dulu ke posisi awal ayat sebelum resume
      // Ini memastikan audio tidak bocor dari detik ke-0
      await _audioPlayer.seek(Duration(seconds: ayat.startTime));

      // 4. Mulai putar
      await _audioPlayer.resume();

      // 5. Jalankan timer untuk mematikan audio sesuai durasi_ideal
      // Kita tambahkan sedikit buffer (misal 200ms) agar tidak terpotong kasar
      _audioTimer = Timer(
        Duration(milliseconds: (ayat.durasiIdeal * 1000).toInt()),
        () async {
          await _audioPlayer.stop();
        },
      );
    } catch (e) {
      print("Error Audio: $e");
    }
  }

  String _normalizeArabic(String text) {
    var exp = RegExp(r'[\u064B-\u0652\u06D6-\u06ED]');
    String result = text.replaceAll(exp, '');
    result = result
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(' ', '');
    return result.trim();
  }

  void startCorrection(Ayat ayat) async {
    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      _userSpeech = "Mendengarkan...";
      _startMicTime = DateTime.now().millisecondsSinceEpoch / 1000;
      notifyListeners();

      _speech.listen(
        localeId: 'ar-SA',
        onResult: (result) {
          _userSpeech = result.recognizedWords;
          if (result.finalResult) {
            _analyzeReading(ayat);
          }
          notifyListeners();
        },
      );
    }
  }

  void _analyzeReading(Ayat target) {
    _isListening = false;
    double endTime = DateTime.now().millisecondsSinceEpoch / 1000;
    double userDuration = endTime - _startMicTime;
    String cleanTarget = _normalizeArabic(target.teks);
    String cleanUser = _normalizeArabic(_userSpeech);

    bool isTextMatch =
        cleanUser.contains(cleanTarget) || cleanTarget.contains(cleanUser);

    if (isTextMatch && cleanUser.isNotEmpty) {
      if (userDuration < (target.durasiIdeal - 1.5)) {
        _correctionStatus = "Lafal Benar, tapi terlalu cepat.";
      } else if (userDuration > (target.durasiIdeal + 4.0)) {
        _correctionStatus = "Lafal Benar, tapi terlalu lambat.";
      } else {
        _correctionStatus = "MasyaAllah! Bacaan & Tajwid Anda Bagus.";
      }
    } else {
      _correctionStatus = "Bacaan kurang tepat. Perhatikan makhraj.";
      playExampleAudio(target); // Auto-play jika salah
    }
    notifyListeners();
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _speech.cancel();
    super.dispose();
  }
}
