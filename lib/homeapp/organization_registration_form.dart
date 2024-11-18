import 'package:flutter/material.dart';

class OrganizationRegistrationForm extends StatefulWidget {
  final Map<String, List<String>> organizations;
  final String? selectedCategory;
  final String? selectedOrganization;
  final String? email;
  final String? password;
  final String? confirmPassword; // Menambahkan konfirmasi password
  final Function(String?) onCategoryChanged;
  final Function(String?) onOrganizationChanged;
  final Function(String) onEmailChanged;
  final Function(String) onPasswordChanged;
  final Function(String) onConfirmPasswordChanged; // Menambahkan fungsi untuk konfirmasi password

  const OrganizationRegistrationForm({
    super.key,
    required this.organizations,
    required this.selectedCategory,
    required this.selectedOrganization,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.onCategoryChanged,
    required this.onOrganizationChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged, String? Organization, // Menambahkan parameter untuk konfirmasi password
  });

  @override
  _OrganizationRegistrationFormState createState() => _OrganizationRegistrationFormState();
}

class _OrganizationRegistrationFormState extends State<OrganizationRegistrationForm> {
  bool _isPasswordVisible = false; // Variabel untuk mengontrol visibilitas password
  bool _isConfirmPasswordVisible =
      false; // Variabel untuk mengontrol visibilitas konfirmasi password

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select Category'),
          value: widget.selectedCategory,
          onChanged: widget.onCategoryChanged,
          items: widget.organizations.keys.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select Organization'),
          value: widget.selectedOrganization,
          onChanged: widget.onOrganizationChanged,
          items: widget.selectedCategory != null
              ? widget.organizations[widget.selectedCategory!]!.map((org) {
                  return DropdownMenuItem<String>(
                    value: org,
                    child: Text(org),
                  );
                }).toList()
              : [],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: 'Email'),
          onChanged: widget.onEmailChanged,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
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
          onChanged: widget.onPasswordChanged,
          obscureText: !_isPasswordVisible,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
          onChanged: widget.onConfirmPasswordChanged,
          obscureText: !_isConfirmPasswordVisible,
        ),
      ],
    );
  }
}
