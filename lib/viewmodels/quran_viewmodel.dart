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

  // Variabel untuk melacak kata yang sedang diputar
  int? _activeWordIndex;

  QuranViewModel() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _activeWordIndex = null;
        notifyListeners();
      }
    });
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
  int? get activeWordIndex => _activeWordIndex;
  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  Ayat get currentAyat => _verses.isNotEmpty
      ? _verses[_currentIndex]
      : Ayat(nomor: 0, teks: "", terjemahan: "", audioPath: "", segments: []);

  Future<void> loadSurah(String fileName) async {
    _isLoading = true;
    notifyListeners();
    try {
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
    _activeWordIndex = null;
    _correctionStatus = "Tahan tombol Mic untuk mengaji...";
  }

  // Play per WordSegment
  Future<void> playWordAudio(int index) async {
    if (_activeWordIndex == index && isPlaying) {
      await _audioPlayer.stop();
      _activeWordIndex = null;
    } else {
      await _audioPlayer
          .stop(); // Berhentikan audio lain yang mungkin sedang jalan
      _activeWordIndex = index;
      notifyListeners();

      final segment = currentAyat.segments[index];
      await _audioPlayer.play(AssetSource(currentAyat.audioPath));
      await _audioPlayer.seek(Duration(milliseconds: segment.start));

      // Hitung durasi kata
      int durationMs = segment.end - segment.start;

      Timer(Duration(milliseconds: durationMs), () async {
        if (_activeWordIndex == index) {
          await _audioPlayer.stop();
          _activeWordIndex = null;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  Future<void> playExampleAudio(Ayat ayat) async {
    if (isPlaying) {
      await _audioPlayer.stop();
    } else {
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
          if (result.finalResult) _analyzeReading(ayat);
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

    List<String> targetWords = target.teks.split(' ');
    List<String> userWords = _userSpeech.split(' ');

    for (int i = 0; i < targetWords.length; i++) {
      String cleanTarget = _normalizeArabic(targetWords[i]);
      bool foundCorrect = false;

      for (String uw in userWords) {
        if (_normalizeArabic(uw).similarityTo(cleanTarget) > 0.6) {
          foundCorrect = true;
          break;
        }
      }

      if (foundCorrect) {
        _successIndices.add(i);
      } else {
        _errorIndices.add(i);
      }
    }

    _accuracyScore = (_successIndices.length / targetWords.length) * 100;

    if (_errorIndices.isNotEmpty) {
      _correctionStatus = "Menyimak kembali kata yang kurang tepat...";
      _autoPlayErrors();
    } else {
      _correctionStatus = "MasyaAllah! Akurasi Sempurna!";
    }
    notifyListeners();
  }

  // Auto Play berurutan untuk kata yang salah (merah)
  Future<void> _autoPlayErrors() async {
    for (int index in _errorIndices) {
      if (index < currentAyat.segments.length) {
        await playWordAudio(index);
        // Tunggu audio selesai + sedikit jeda sebelum kata berikutnya
        int duration =
            currentAyat.segments[index].end - currentAyat.segments[index].start;
        await Future.delayed(Duration(milliseconds: duration + 400));
      }
    }
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u0652\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
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
