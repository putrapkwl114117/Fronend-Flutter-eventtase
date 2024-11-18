import 'package:flutter/material.dart';

class OrganizationButton extends StatelessWidget {
  const OrganizationButton({super.key, required Future<Null> Function() onPressed, required Text child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Action for registering organization
        Navigator.pushNamed(context, '/register-organization');
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Daftarkan Organisasi Anda',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
