import 'package:eventtase/dashboard_organisasi/event_card.dart';
import 'package:eventtase/dashboard_organisasi/event_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required String organizationId});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final storage = const FlutterSecureStorage();
  String organizationName = '';
  String? organizationId;
  List<Map<String, dynamic>> events = []; // Menggunakan dynamic untuk tipe data yang lebih fleksibel

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
  }

  // Memuat data organisasi (termasuk organizationId) dan events dari storage serta API
  Future<void> _loadOrganizationData() async {
    String? name = await storage.read(key: 'organizationName');
    String? id = await storage.read(key: 'organizationId');

    setState(() {
      organizationName = name ?? 'Organisasi Anda';
      organizationId = id; // Simpan organizationId yang dibaca
    });

    if (organizationId != null) {
      // Ambil daftar event berdasarkan organizationId dari backend
      await _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    final url = 'http://10.0.2.2:8000/api/events/$organizationId'; // Pastikan $organizationId sudah ada
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${await storage.read(key: 'authToken')}' // Kirim token otentikasi jika diperlukan
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Pastikan data adalah array (List) dan iterasi dengan benar
      setState(() {
        events = List<Map<String, dynamic>>.from(data.map((event) {
          return {
            'name': event['name'],             // Ambil name
            'description': event['description'], // Ambil description
            'imagePath': event['image_path'],   // Ambil image_path
          };
        }).toList()); // Pastikan menjadi List<Map<String, dynamic>>
      });
    } else {
      // Tampilkan pesan kesalahan jika API gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat event')),
      );
    }
  }

  // Fungsi untuk logout dan navigasi
  Future<void> _logout() async {
    await storage.delete(key: 'authToken');
    await storage.delete(key: 'isOrganizationRegistered');
    await storage.delete(key: 'organizationId');
    Navigator.of(context).pushReplacementNamed('/welcome');
  }

  void _navigateTo(String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  // Fungsi untuk menampilkan form pembuatan event
  void _showCreateEventForm() async {
    if (organizationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap daftarkan organisasi terlebih dahulu!")),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateEventForm(
        onEventCreated: (newEvent) {
          setState(() {
            events.add(newEvent);
          });
        },
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event created successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.signOutAlt),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueAccent),
              child: Text(
                'Selamat datang, $organizationName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.fileAlt),
              title: const Text('Lihat Laporan'),
              onTap: () => _navigateTo('/lihat-laporan'),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.cogs),
              title: const Text('Pengaturan Organisasi'),
              onTap: () => _navigateTo('/pengaturan'),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.users),
              title: const Text('Daftar Peserta'),
              onTap: () => _navigateTo('/daftar-peserta'),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tampilkan daftar event
          for (var event in events)
            EventCard(
              title: event['name'] ?? 'No Name',
              description: event['description'] ?? 'No Description',
              imagePath: event['imagePath'] ?? '',
            ),
          ElevatedButton(
            onPressed: _showCreateEventForm,
            child: const Text("Create Event"),
          ),
        ],
      ),
    );
  }
}
