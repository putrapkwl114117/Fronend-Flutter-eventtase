import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EventRegistrationForm extends StatefulWidget {
  const EventRegistrationForm({super.key});

  @override
  _EventRegistrationFormState createState() => _EventRegistrationFormState();
}

class _EventRegistrationFormState extends State<EventRegistrationForm> {
  final storage = const FlutterSecureStorage();
  String? selectedCategory;
  String? selectedOrganization;
  String? email;
  String? password;
  String? confirmPassword;
  bool isLoading = false;
  String? successMessage;
  String? errorMessage;

  final Map<String, List<String>> organizations = {
    'Minat dan Bakat': ['UKM Komusikani Unjaya', 'UKM Futsal'],
  };

  @override
  void initState() {
    super.initState();
    _loadSuccessMessage();
  }

  Future<void> _loadSuccessMessage() async {
    final message = await storage.read(key: 'successMessage');
    if (message != null) {
      setState(() {
        successMessage = message;
      });
      await storage.delete(key: 'successMessage');
    }
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  Future<void> submitRegistration() async {
    if (selectedCategory == null ||
        selectedOrganization == null ||
        email == null ||
        email!.isEmpty ||
        !_isValidEmail(email!) ||
        password == null ||
        password!.isEmpty ||
        confirmPassword == null ||
        confirmPassword!.isEmpty ||
        password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap isi semua field dan pastikan password cocok serta email valid!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String? token = await storage.read(key: 'token');
      String? userId = await storage.read(key: 'userId');

      if (userId == null || token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID atau Token tidak ditemukan. Silakan login kembali.'),
          ),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/register-organization'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'category': selectedCategory!,
          'organization_name': selectedOrganization!,
          'email': email!,
          'password': password!,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        String organizationId = responseBody['organization']['id'].toString();

        await storage.write(key: 'organizationId', value: organizationId);
        await storage.write(key: 'isOrganizationRegistered_$userId', value: 'true');

        setState(() {
          successMessage = responseBody['message'];
          selectedCategory = null;
          selectedOrganization = null;
          email = null;
          password = null;
          confirmPassword = null;
        });

        Navigator.pop(context);
      } else {
        final responseBody = json.decode(response.body);
        setState(() {
          errorMessage = responseBody['message'] ?? 'Gagal mendaftar!';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Organization'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (successMessage != null)
                Text(
                  successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedOrganization = null;
                  });
                },
                items: organizations.keys.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedOrganization,
                onChanged: (value) {
                  setState(() {
                    selectedOrganization = value;
                  });
                },
                items: selectedCategory == null
                    ? []
                    : organizations[selectedCategory]!
                        .map((org) => DropdownMenuItem(value: org, child: Text(org)))
                        .toList(),
                decoration: const InputDecoration(labelText: 'Organization'),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => email = value,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => password = value,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => confirmPassword = value,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitRegistration,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Register Organization'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
