class Ayat {
  final int nomor;
  final String teks;
  final String terjemahan;
  final double durasiIdeal;

  Ayat({
    required this.nomor,
    required this.teks,
    required this.terjemahan,
    required this.durasiIdeal,
  });
}

// Data dummy untuk demo
final ayat1Ikhlas = Ayat(
  nomor: 1,
  teks: "قُلْ هُوَ اللَّهُ أَحَدٌ",
  terjemahan: "Katakanlah: Dialah Allah, Yang Maha Esa",
  durasiIdeal: 3.5,
);

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
