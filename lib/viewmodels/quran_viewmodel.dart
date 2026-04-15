import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/quran_model.dart';

class QuranViewModel extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _audioTimer;

  List<Ayat> _verses = [];
  int _currentIndex = 0;
  bool _isListening = false;
  String _userSpeech = "";
  String _correctionStatus = "Tahan tombol Mic untuk mengaji...";
  bool _isLoading = false;
  int _activeWordIndex = -1; // Getter untuk UI Highlighting

  // Getters
  List<Ayat> get verses => _verses;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String get correctionStatus => _correctionStatus;
  int get activeWordIndex => _activeWordIndex;
  Ayat get currentAyat => _verses[_currentIndex];
  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  Future<void> loadSurahData(String fileName) async {
    _isLoading = true;
    _currentIndex = 0;
    _activeWordIndex = -1;
    notifyListeners();
    try {
      final String response = await rootBundle.loadString(
        'assets/data/$fileName',
      );
      final data = json.decode(response);
      _verses = (data['verses'] as List).map((i) => Ayat.fromJson(i)).toList();
    } catch (e) {
      debugPrint("Error Load Data: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // Audio Fix: Play Full Ayat (Qori)
  Future<void> playFullAudio(Ayat ayat) async {
    await stopAllAudio();
    await _audioPlayer.play(AssetSource(ayat.audioPath));
    notifyListeners();
  }

  // Audio Fix: Play Per Kata dengan Timer Cancel agar tidak tumpang tindih
  void playWordAudio(WordSegment seg, int index) async {
    _audioTimer?.cancel(); // Menghentikan timer sebelumnya jika ada klik cepat
    await _audioPlayer.stop(); // Hentikan audio yang sedang jalan

    _activeWordIndex = index;
    notifyListeners();

    await _audioPlayer.play(AssetSource(currentAyat.audioPath));
    await _audioPlayer.seek(Duration(milliseconds: seg.start));

    _audioTimer = Timer(Duration(milliseconds: seg.end - seg.start), () {
      _audioPlayer.stop();
      _activeWordIndex = -1;
      notifyListeners();
    });
  }

  Future<void> stopAllAudio() async {
    _audioTimer?.cancel();
    _activeWordIndex = -1;
    await _audioPlayer.stop();
    notifyListeners();
  }

  // Navigasi
  void nextAyat() {
    if (_currentIndex < _verses.length - 1) {
      _currentIndex++;
      _activeWordIndex = -1;
      _correctionStatus = "Tahan tombol Mic untuk mengaji...";
      stopAllAudio();
      notifyListeners();
    }
  }

  void previousAyat() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _activeWordIndex = -1;
      _correctionStatus = "Tahan tombol Mic untuk mengaji...";
      stopAllAudio();
      notifyListeners();
    }
  }

  // Speech to Text
  Future<void> startListening(Ayat ayat) async {
    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      _userSpeech = "";
      _correctionStatus = "Mendengarkan...";
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
    if (_userSpeech.isNotEmpty) {
      _correctionStatus = "Selesai Membaca";
    }
    notifyListeners();
  }
}
