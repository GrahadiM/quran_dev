import 'package:flutter/material.dart';
import '../models/quran_model.dart';

class AuthViewModel extends ChangeNotifier {
  // Data Dummy Kelas
  final List<UserSession> _dummyClasses = [
    UserSession(className: "Kelas 7A", pin: "777777", limit: 30),
    UserSession(className: "Kelas 8A", pin: "888888", limit: 40),
    UserSession(className: "Kelas 9A", pin: "999999", limit: 50),
  ];

  bool _isLoggedIn = false;
  String? _currentClass;
  String _errorMessage = "";

  bool get isLoggedIn => _isLoggedIn;
  String? get currentClass => _currentClass;
  String get errorMessage => _errorMessage;

  void login(String enteredPin) {
    try {
      // Logic If-Else untuk Demo
      var matchedClass = _dummyClasses.firstWhere((c) => c.pin == enteredPin);

      _isLoggedIn = true;
      _currentClass = matchedClass.className;
      _errorMessage = "";
      notifyListeners();
    } catch (e) {
      _errorMessage = "PIN Salah atau Kelas Tidak Ditemukan!";
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _currentClass = null;
    notifyListeners();
  }
}
