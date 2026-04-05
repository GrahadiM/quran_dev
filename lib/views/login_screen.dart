import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/quran_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Masukkan 6 Digit PIN Kelas", style: TextStyle(fontSize: 18)),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                errorText: authVM.errorMessage.isEmpty
                    ? null
                    : authVM.errorMessage,
              ),
            ),
            ElevatedButton(
              onPressed: () => authVM.login(_pinController.text),
              child: Text("Masuk"),
            ),
          ],
        ),
      ),
    );
  }
}
