import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:string_similarity/string_similarity.dart';
import '../models/quran_model.dart';

class QuranViewModel extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Ayat> _verses = [];
  int _currentIndex = 0;
  bool _isListening = false;
  String _userSpeech = "";
  String _correctionStatus = "Tahan tombol Mic untuk mengaji...";
  bool _isLoading = false;

  List<int> _errorIndices = [];
  List<int> _successIndices = [];
  double _accuracyScore = 0.0;

  QuranViewModel() {
    _audioPlayer.onPlayerStateChanged.listen((state) => notifyListeners());
  }

  // Getters
  List<Ayat> get verses => _verses;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String get userSpeech => _userSpeech;
  String get correctionStatus => _correctionStatus;
  List<int> get errorIndices => _errorIndices;
  List<int> get successIndices => _successIndices;
  double get accuracyScore => _accuracyScore;
  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  Ayat get currentAyat => _verses.isNotEmpty
      ? _verses[_currentIndex]
      : Ayat(nomor: 0, teks: "", terjemahan: "", audioPath: "", segments: []);

  Future<void> loadSurah(String fileName) async {
    _isLoading = true;
    _verses = []; // Reset list agar UI menunjukkan loading yang bersih
    notifyListeners();

    try {
      // PERBAIKAN: Sesuaikan path ke 'assets/data/' sesuai pubspec.yaml
      final String response = await rootBundle.loadString(
        'assets/data/$fileName',
      );
      final data = json.decode(response);
      _verses = (data['verses'] as List).map((i) => Ayat.fromJson(i)).toList();
      _currentIndex = 0;
      _resetFeedback();
    } catch (e) {
      debugPrint("Gagal memuat Surah: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _resetFeedback() {
    _userSpeech = "";
    _errorIndices.clear();
    _successIndices.clear();
    _accuracyScore = 0.0;
    _correctionStatus = "Tahan tombol Mic untuk mengaji...";
  }

  Future<void> playExampleAudio(Ayat ayat) async {
    if (isPlaying) {
      await _audioPlayer.stop();
    } else {
      // Pastikan audioPath di JSON sesuai dengan folder di pubspec
      await _audioPlayer.play(AssetSource(ayat.audioPath));
    }
    notifyListeners();
  }

  void startListening(Ayat ayat) async {
    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      _resetFeedback();
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

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  void _analyzeReading(Ayat target) {
    _isListening = false;
    _errorIndices.clear();
    _successIndices.clear();

    // Memecah teks target menjadi list kata
    List<String> targetWords = target.teks.split(' ');
    // Memecah hasil ucapan user menjadi list kata
    List<String> userWords = _userSpeech.split(' ');

    for (int i = 0; i < targetWords.length; i++) {
      String cleanTarget = _normalizeArabic(targetWords[i]);
      bool foundCorrect = false;

      // Mencari apakah kata target ada dalam ucapan user (dengan toleransi kemiripan)
      for (String uw in userWords) {
        String cleanUser = _normalizeArabic(uw);
        if (cleanUser == cleanTarget ||
            cleanUser.similarityTo(cleanTarget) > 0.6) {
          foundCorrect = true;
          break;
        }
      }

      if (foundCorrect) {
        _successIndices.add(i); // Masuk ke list hijau
      } else {
        _errorIndices.add(i); // Masuk ke list merah
      }
    }

    _accuracyScore = (_successIndices.length / targetWords.length) * 100;

    if (_errorIndices.isEmpty && _successIndices.isNotEmpty) {
      _correctionStatus = "MasyaAllah! Akurasi Sempurna!";
      HapticFeedback.lightImpact();
    } else {
      _correctionStatus =
          "Akurasi: ${_accuracyScore.toStringAsFixed(0)}%. Perbaiki kata yang merah.";
      HapticFeedback.vibrate();
    }
    notifyListeners();
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u0652\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[^\u0621-\u064A\s]'), '')
        .trim();
  }

  void nextAyat() {
    if (_currentIndex < _verses.length - 1) {
      _currentIndex++;
      _resetFeedback();
      _audioPlayer.stop();
      notifyListeners();
    }
  }

  void previousAyat() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _resetFeedback();
      _audioPlayer.stop();
      notifyListeners();
    }
  }
}
