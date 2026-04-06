class Ayat {
  final int nomor;
  final String teks;
  final String terjemahan;
  final String audioPath;
  final int startTime;
  final double durasiIdeal;

  Ayat({
    required this.nomor,
    required this.teks,
    required this.terjemahan,
    required this.audioPath,
    required this.startTime,
    required this.durasiIdeal,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      nomor: json['number'],
      teks: json['text'],
      terjemahan: json['translation'],
      audioPath: json['audio_path'],
      startTime: json['start_time'] ?? 0,
      durasiIdeal: (json['duration'] as num).toDouble(),
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
