// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ResetPasswordScreen extends StatefulWidget {
//   final String token; // Token dari tautan reset password

//   const ResetPasswordScreen({super.key, required this.token});

//   @override
//   _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   String? _message;
//   bool _isLoading = false;

//   void _resetPassword() async {
//     setState(() {
//       _isLoading = true;
//       _message = null;
//     });

//     if (_passwordController.text != _confirmPasswordController.text) {
//       setState(() {
//         _message = 'Password dan konfirmasi password tidak cocok.';
//         _isLoading = false;
//       });
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('https://7469-36-68-60-71.ngrok-free.app/api/reset-password'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'token': widget.token,
//           'password': _passwordController.text,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _message = data['status'];
//         });

//         // Setelah berhasil, arahkan kembali ke halaman login
//         Future.delayed(const Duration(seconds: 2), () {
//           Navigator.pop(context); // Kembali ke halaman sebelumnya (halaman login)
//         });
//       } else {
//         final data = json.decode(response.body);
//         setState(() {
//           _message = data['message'] ?? 'Terjadi kesalahan, silakan coba lagi.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _message = 'Terjadi kesalahan. Silakan coba lagi.';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reset Password'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Masukkan password baru Anda.',
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             if (_message != null) ...[
//               Text(
//                 _message!,
//                 style: const TextStyle(color: Colors.red),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//             ],
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(
//                 hintText: 'Password Baru',
//                 border: OutlineInputBorder(),
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _confirmPasswordController,
//               decoration: const InputDecoration(
//                 hintText: 'Konfirmasi Password',
//                 border: OutlineInputBorder(),
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _resetPassword,
//               child: Text(_isLoading ? 'Mengirim...' : 'Reset Password'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
