import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class CreateEventForm extends StatefulWidget {
  const CreateEventForm({super.key, required this.onEventCreated});

  final Function(Map<String, String> newEvent) onEventCreated;

  @override
  _CreateEventFormState createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final storage = const FlutterSecureStorage();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  String? _organizationId;

  @override
  void initState() {
    super.initState();
    _loadOrganizationId();
    _requestPermissions();
  }

  Future<void> _loadOrganizationId() async {
    final id = await storage.read(key: 'organizationId');
    if (id == null) {
      _showSnackBar("Organization ID is missing. Please log in again.", isError: true);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _organizationId = id;
      });
    }
  }

  Future<void> _requestPermissions() async {
    PermissionStatus storagePermission = await Permission.storage.request();
    PermissionStatus cameraPermission = await Permission.camera.request();

    if (!storagePermission.isGranted || !cameraPermission.isGranted) {
      _showSnackBar("Please grant the necessary permissions for camera and storage.", isError: true);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (error) {
      _showSnackBar("Failed to pick image: $error", isError: true);
    }
  }

  void _submitForm() async {
    final String eventName = _nameController.text.trim();
    final String eventDescription = _descriptionController.text.trim();

    if (_organizationId == null) {
      _showSnackBar("Organization ID is missing. Please log in again.", isError: true);
      return;
    }
    if (eventName.isEmpty || eventDescription.isEmpty) {
      _showSnackBar("Event name and description are required.", isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri = Uri.parse('http://10.0.2.2:8000/api/events');
      final request = http.MultipartRequest('POST', uri);

      // Mengirimkan data ke API
      request.fields['organization_id'] = _organizationId!;
      request.fields['name'] = eventName;
      request.fields['description'] = eventDescription;

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = json.decode(responseBody);

      if (response.statusCode == 200 && decodedResponse['event'] != null) {
        // Mengonversi data API menjadi Map<String, String> untuk konsistensi
        Map<String, String> newEvent = {
          'name': decodedResponse['event']['name'],
          'description': decodedResponse['event']['description'],
          'imagePath': decodedResponse['event']['image_path'] ?? '',
        };

        widget.onEventCreated(newEvent); // Kirim event baru ke DashboardPage
        _showSnackBar("Event created successfully.");
        Navigator.pushReplacementNamed(context, '/dashboard-organization');
      } else {
        final errorMessage = decodedResponse['error'] ?? 'Unknown error';
        _showSnackBar("Failed to create event: $errorMessage", isError: true);
      }
    } catch (error) {
      _showSnackBar("Error occurred: $error", isError: true);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Event Description'),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image"),
            ),
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                width: 100,
                height: 100,
              ),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitForm,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
