import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/quran_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/pilih_surat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => QuranViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Implementasi Palet Warna Kustom
    const Color textDefault = Color(0xFF020202);
    const Color textPrimary = Color(0xFF059212);
    const Color textSecondary = Color(0xFF9BEC00);
    const Color backgroundDefault = Color(0xFFFFFFFF);
    const Color backgroundPrimary = Color(0xFF346739);
    const Color backgroundSecondary = Color(0xFFF3FF90);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quran Dev',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Amiri', // Memastikan nuansa Islami pada teks
        scaffoldBackgroundColor: backgroundDefault,

        // Konfigurasi Skema Warna
        colorScheme: ColorScheme.fromSeed(
          seedColor: textPrimary,
          primary: textPrimary,
          secondary: textSecondary,
          surface: backgroundDefault,
          onSurface: textDefault,
        ),

        // AppBar menggunakan Background Primary (Hijau Tua)
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundPrimary,
          foregroundColor: backgroundDefault, // Putih untuk kontras
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: backgroundDefault,
          ),
          iconTheme: IconThemeData(color: backgroundDefault),
        ),

        // Card menggunakan kombinasi Background Secondary (Kuning Muda/Lime)
        cardTheme: CardThemeData(
          color: backgroundSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: textSecondary, width: 1),
          ),
        ),

        // Pengaturan Teks Global
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textDefault),
          bodyMedium: TextStyle(color: textDefault),
          titleLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Desain Tombol menggunakan Text Primary
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: textPrimary,
            foregroundColor: backgroundDefault,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ListTile (untuk daftar surat)
        listTileTheme: const ListTileThemeData(
          textColor: textDefault,
          iconColor: textPrimary,
        ),
      ),

      home: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: authVM.isLoggedIn ? const PilihSuratScreen() : LoginScreen(),
          );
        },
      ),
    );
  }
}
