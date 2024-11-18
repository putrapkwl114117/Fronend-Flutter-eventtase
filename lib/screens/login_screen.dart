import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../components/custom_textfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isPasswordVisible = false;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadSuccessMessage();
  }

  Future<void> _loadSuccessMessage() async {
    final successMessage = await _storage.read(key: 'successMessage');
    if (successMessage != null) {
      setState(() {
        _successMessage = successMessage;
      });
      await _storage.delete(key: 'successMessage'); // Hapus pesan setelah dibaca
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://3260-125-163-241-188.ngrok-free.app/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userId = data['user']['id'].toString();

        // Simpan token menggunakan FlutterSecureStorage
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'userId', value: userId);

        // Arahkan ke halaman utama setelah login
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Tampilkan pesan error jika login gagal
        final data = json.decode(response.body);
        setState(() {
          _errorMessage = data['message'];
        });
      }
    } catch (e) {
      // Tangani kesalahan jaringan
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
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
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome back! Glad to see you, Again!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Tampilkan pesan sukses jika ada
            if (_successMessage != null) ...[
              Text(
                _successMessage!,
                style: const TextStyle(color: Colors.green),
              ),
              const SizedBox(height: 20),
            ],
            // Tampilkan pesan error jika ada
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
            ],
            CustomTextField(
              hintText: 'Enter your email',
              controller: _emailController,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, '/forgot-password'); // Navigasi ke ForgotPasswordScreen
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: _isLoading ? 'Loading...' : 'Login',
              onPressed: _isLoading ? null : _login,
            ),
            const SizedBox(height: 10),
            const Text('Or Login with'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.google),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.apple),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Don\'t have an account? Register Now'),
            ),
          ],
        ),
      ),
    );
  }
}
