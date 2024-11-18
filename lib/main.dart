 import 'package:eventtase/dashboard_organisasi/dashboard_page.dart';
import 'package:eventtase/homeapp/event_registration_form.dart';
import 'package:eventtase/homeapp/home_page.dart';
import 'package:eventtase/screens/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fruzz Digital',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterScreen(),
        '/register-organization': (context) => const EventRegistrationForm(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashbord-organization': (context) => const DashboardPage(),
      },
    );
  }
}