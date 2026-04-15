class Ayat {
  final int nomor;
  final String teks;
  final String terjemahan;
  final double durasiIdeal;
  final double audioDuration;
  final String audioPath;
  final int startTime;

  Ayat({
    required this.nomor,
    required this.teks,
    required this.terjemahan,
    required this.durasiIdeal,
    required this.audioDuration,
    required this.audioPath,
    required this.startTime,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      nomor: json['number'],
      teks: json['text'],
      terjemahan: json['translation'],
      durasiIdeal: (json['ideal_duration'] as num).toDouble(),
      audioDuration: (json['audio_duration'] as num).toDouble(),
      audioPath: json['audio_path'],
      startTime: json['start_time'] ?? 0,
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
