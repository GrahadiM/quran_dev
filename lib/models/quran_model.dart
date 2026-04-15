class WordSegment {
  final String word;
  final int start;
  final int end;

  WordSegment({required this.word, required this.start, required this.end});

  factory WordSegment.fromJson(Map<String, dynamic> json) {
    return WordSegment(
      word: json['word'],
      start: json['start'],
      end: json['end'],
    );
  }
}

class Ayat {
  final int nomor;
  final String teks;
  final String terjemahan;
  final String audioPath;
  final List<WordSegment> segments;

  Ayat({
    required this.nomor,
    required this.teks,
    required this.terjemahan,
    required this.audioPath,
    required this.segments,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    var list = json['segments'] as List? ?? [];
    List<WordSegment> segmentList = list
        .map((i) => WordSegment.fromJson(i))
        .toList();

    return Ayat(
      nomor: json['number'],
      teks: json['text'],
      terjemahan: json['translation'],
      audioPath: json['audio_path'],
      segments: segmentList,
    );
  }
}

class UserSession {
  final String className;
  final String pin;
  final int limit;

  UserSession({
    required this.className,
    required this.pin,
    required this.limit,
  });
}
