# quran_dev

Aplikasi Al-Quran pintar yang dikembangkan oleh **Hadoy Dev**. Proyek ini fokus pada fitur koreksi bacaan mandiri (tahsin) menggunakan teknologi pengenalan suara dan analisis kemiripan teks.

## Fitur Utama

- **Navigasi & Filter:** Pemilihan surat yang intuitif dengan daftar yang terorganisir.
- **Audio Playback:**
  - Putar murottal per ayat secara utuh.
  - Putar audio per segmen/huruf untuk detail pelafalan yang lebih presisi menggunakan library `audioplayers`.
- **Teks & Terjemahan:** Tampilan teks Arab menggunakan font **Amiri** yang elegan beserta artinya dalam Bahasa Indonesia.
- **AI Voice Correction:**
  - Menggunakan `speech_to_text` untuk menangkap input suara pengguna.
  - Menggunakan algoritma `string_similarity` untuk membandingkan akurasi bacaan pengguna dengan teks asli.
  - **Feedback Visual:** Teks berubah warna menjadi **Hijau** (Benar) atau **Merah** (Salah/Kurang tepat).
  - **Feedback Audio:** Otomatis memutar audio potongan segmen jika terdapat kesalahan pada bagian tertentu.

## 🛠️ Tech Stack & Dependencies

Aplikasi ini dibangun menggunakan **Flutter** dengan beberapa package utama:

* **`provider`**: State management untuk mengelola alur data aplikasi.
* **`speech_to_text`**: Untuk fitur pengenalan suara saat user mengaji.
* **`audioplayers` (6.6.0)**: Mesin pemutar audio untuk murottal dan potongan ayat.
* **`string_similarity`**: Algoritma untuk menghitung skor akurasi bacaan.
* **`scrollable_positioned_list`**: Untuk navigasi list ayat yang lebih smooth.

## 📂 Struktur Aset

Aplikasi menggunakan data lokal (JSON) dan file audio yang telah dipetakan di `pubspec.yaml`:
- **Data Surat:** `assets/data/` (Contoh: Al-Ikhlash, Al-Falaq, An-Nas).
- **Audio:** `assets/audio/` (Audio utuh dan potongan per ayat/segmen).
- **Fonts:** Menggunakan font **Amiri-Regular** dan **Amiri-Bold** untuk kenyamanan membaca teks Arab.

## 🚀 Memulai Proyek

1. **Prasyarat:**
   - Flutter SDK versi `^3.9.2` atau lebih baru.
   - Perangkat Android/iOS dengan dukungan Mikrofon.

2. **Instalasi:**
   ```bash
   # Clone repository
   git clone [https://github.com/username/quran_dev.git](https://github.com/username/quran_dev.git)

   # Masuk ke folder proyek
   cd quran_dev

   # Ambil dependensi
   flutter pub get