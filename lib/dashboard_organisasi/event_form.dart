import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class CreateEventForm extends StatefulWidget {
  const CreateEventForm({super.key, required this.onEventCreated});

  final Function(dynamic newEvent) onEventCreated; // Callback to notify success

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
  }

  Future<void> _loadOrganizationId() async {
    final id = await storage.read(key: 'organizationId');
    if (id == null) {
      _showSnackBar("Organization ID is missing. Please log in again.");
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _organizationId = id;
      });
    }
  }

  // Pick an image from the gallery without blocking the UI
  Future<void> _pickImage() async {
    // Request permission to access photos and storage
    PermissionStatus storagePermission = await Permission.storage.request();
    PermissionStatus cameraPermission = await Permission.camera.request();

    if (storagePermission.isGranted && cameraPermission.isGranted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      } catch (error) {
        _showSnackBar("Failed to pick image: $error");
      }
    } else {
      _showSnackBar("Permission to access storage or camera is denied.");
    }
  }

  void _submitForm() async {
    final String eventName = _nameController.text.trim();
    final String eventDescription = _descriptionController.text.trim();

    if (_organizationId == null) {
      _showSnackBar("Organization ID is missing. Please log in again.");
      return;
    }
    if (eventName.isEmpty || eventDescription.isEmpty) {
      _showSnackBar("Event name and description are required.");
      return;
    }
    if (_imageFile == null) {
      _showSnackBar("Please select an image.");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri = Uri.parse('https://2e93-125-160-100-230.ngrok-free.app/api/events');
      final request = http.MultipartRequest('POST', uri);

      request.fields['name'] = eventName;
      request.fields['description'] = eventDescription;
      request.fields['organization_id'] = _organizationId!;

      // Log the file path to ensure it is valid
      print("Uploading file: ${_imageFile!.path}");
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        // Notify success
        widget.onEventCreated(decodedResponse); // Callback for successful creation
        _showSnackBar("Event created successfully.");

        // Navigate back to the dashboard after successful creation
        Navigator.pushReplacementNamed(context, '/dashboard-organization');
      } else {
        _showSnackBar("Failed to create event: ${decodedResponse['error'] ?? 'Unknown error'}");
      }
    } catch (error, stacktrace) {
      print("Error occurred: $error");
      print("Stack trace: $stacktrace");
      _showSnackBar("Error occurred: $error");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Event Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Choose Image"),
            ),
            _imageFile != null
                ? Image.file(_imageFile!, height: 100, width: 100)
                : const SizedBox(),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Create Event'),
                  ),
          ],
        ),
      ),
    );
  }
}
