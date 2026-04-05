import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/quran_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/detail_surah_screen.dart';

void main() {
  runApp(
    // Inisialisasi beberapa ViewModel sekaligus
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Al-Qur’an PIN',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Amiri', // Pastikan sudah daftar di pubspec.yaml
      ),
      // Logic Navigasi: Jika sudah login masuk ke Surah, jika belum ke Login
      home: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          return authVM.isLoggedIn ? const DetailSurahScreen() : LoginScreen();
        },
      ),
    );
  }
}
