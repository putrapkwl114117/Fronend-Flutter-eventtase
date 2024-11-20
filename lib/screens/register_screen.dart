import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/custom_button.dart';
import '../components/custom_textfield.dart';
import 'package:eventtase/components/loading_widget.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _register() async {
    // Validasi Form
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage("Passwords do not match.", Colors.red);
      return;
    }
    if (_passwordController.text.length < 6) {
      _showMessage("Password must be at least 6 characters.", Colors.red);
      return;
    }
    if (_emailController.text.isEmpty || _nameController.text.isEmpty) {
      _showMessage("All fields are required.", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://2e93-125-160-100-230.ngrok-free.app/api/register'),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      },
    );

    if (response.statusCode == 201) {
      _saveSuccessMessage('Registration successful! Please log in.');
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final errorResponse = jsonDecode(response.body);

      // Menampilkan pesan kesalahan spesifik dari server
      String errorMessage = 'Registration failed. Please try again.';
      if (errorResponse['message'] != null) {
        errorMessage = errorResponse['message'];
      } else if (errorResponse['errors'] != null) {
        // Mengumpulkan pesan kesalahan dari `errors` server response
        errorMessage = (errorResponse['errors'] as Map<String, dynamic>)
            .values
            .map((error) => error[0])
            .join('\n');
      }

      _showMessage(errorMessage, Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _saveSuccessMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('successMessage', message);
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: const BackButton(),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create your account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: 'Enter your name',
                  controller: _nameController,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'Enter your email',
                  controller: _emailController,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  togglePasswordVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'Confirm your password',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  isPasswordVisible: _isConfirmPasswordVisible,
                  togglePasswordVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Register',
                  onPressed: _isLoading ? null : _register,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Already have an account? Login Now'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
              child: const Center(
                child: LoadingWidget(),
              ),
            ),
        ],
      ),
    );
  }
}
