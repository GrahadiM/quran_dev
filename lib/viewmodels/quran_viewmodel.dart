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
  Timer? _audioTimer;
  StreamSubscription? _playerStateSubscription;

  List<Ayat> _verses = [];
  int _currentIndex = 0;
  bool _isListening = false;
  String _userSpeech = "";
  String _correctionStatus = "Tahan tombol Mic untuk mengaji...";
  bool _isLoading = false;

  QuranViewModel() {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      notifyListeners();
    });
  }

  // Getters
  List<Ayat> get verses => _verses;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String get userSpeech => _userSpeech;
  String get correctionStatus => _correctionStatus;
  Ayat get currentAyat => _verses.isNotEmpty
      ? _verses[_currentIndex]
      : Ayat(
          nomor: 0,
          teks: "",
          terjemahan: "",
          durasiIdeal: 0,
          audioDuration: 0,
          audioPath: "",
          startTime: 0,
        );
  bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  Future<void> loadSurahData(String fileName) async {
    _verses = [];
    _currentIndex = 0;
    _isLoading = true;
    _userSpeech = "";
    _correctionStatus = "Tahan tombol Mic untuk mengaji...";

    await _forceStopAudio();
    notifyListeners();

    try {
      final String response = await rootBundle.loadString(
        'assets/data/$fileName',
      );
      final data = json.decode(response);
      var list = data['verses'] as List;
      _verses = list.map((i) => Ayat.fromJson(i)).toList();
    } catch (e) {
      _correctionStatus = "Gagal memuat data.";
    }

    _isLoading = false;
    notifyListeners();
  }

  void nextAyat() {
    if (_currentIndex < _verses.length - 1) {
      _currentIndex++;
      _resetState();
    }
  }

  void previousAyat() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _resetState();
    }
  }

  void _resetState() {
    _forceStopAudio();
    _userSpeech = "";
    _correctionStatus = "Tahan tombol Mic untuk mengaji...";
    notifyListeners();
  }

  Future<void> _forceStopAudio() async {
    try {
      _audioTimer?.cancel();
      if (_audioPlayer.state != PlayerState.stopped) {
        await _audioPlayer.stop();
      }
    } catch (e) {
      debugPrint("Silent error on stop: $e");
    }
  }

  // FIXED PLAY/STOP WITH ERROR HANDLING
  void playExampleAudio(Ayat ayat) async {
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _forceStopAudio();
        return;
      }

      _audioTimer?.cancel();

      // Gunakan try-catch khusus di dalam blok async
      await _audioPlayer
          .play(
            AssetSource(ayat.audioPath),
            position: Duration(seconds: ayat.startTime),
          )
          .catchError((error) {
            debugPrint("Audio Player Error: $error");
            _correctionStatus = "File audio tidak ditemukan.";
            notifyListeners();
          });

      _audioTimer = Timer(
        Duration(milliseconds: (ayat.audioDuration * 1000).toInt()),
        () async => await _forceStopAudio(),
      );
    } catch (e) {
      debugPrint("General Audio Error: $e");
    }
  }

  void startCorrection(Ayat ayat) async {
    await _forceStopAudio();
    try {
      bool available = await _speech.initialize(
        onError: (val) => debugPrint("Speech Error: $val"),
      );
      if (available) {
        _isListening = true;
        _userSpeech = "";
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
    } catch (e) {
      debugPrint("STT Init Error: $e");
    }
  }

  void _analyzeReading(Ayat target) {
    _isListening = false;
    String cleanTarget = _normalizeArabic(target.teks);
    String cleanUser = _normalizeArabic(_userSpeech);

    double similarity = cleanUser.similarityTo(cleanTarget);
    double lengthRatio = cleanTarget.isEmpty
        ? 0
        : cleanUser.length / cleanTarget.length;

    if (similarity >= 0.8 && (lengthRatio >= 0.7 && lengthRatio <= 1.3)) {
      _correctionStatus = "MasyaAllah! Bacaan Anda Bagus.";
    } else {
      _correctionStatus = "Bacaan tidak sesuai. Coba lagi.";
    }
    notifyListeners();
  }

  String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u0652\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(' ', '')
        .trim();
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioTimer?.cancel();
    _audioPlayer.dispose();
    _speech.cancel();
    super.dispose();
  }
}
