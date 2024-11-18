import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _message;
  bool _isLoading = false;
  bool _isSuccess = false;

  void _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _message = 'Masukkan email yang valid.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://bff2-36-80-218-23.ngrok-free.app/api/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _message = data['status']; // Pesan sukses dari server
          _isSuccess = true;
        });
      } else {
        final data = json.decode(response.body);
        setState(() {
          _message = data['email'] ?? 'Terjadi kesalahan, silakan coba lagi.';
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Terjadi kesalahan. Silakan coba lagi.';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Masukkan email Anda untuk menerima tautan reset password.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_message != null) ...[
              Text(
                _message!,
                style: TextStyle(
                  color: _isSuccess ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Masukkan email Anda',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendResetLink,
              child: Text(_isLoading ? 'Mengirim...' : 'Kirim Tautan Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
