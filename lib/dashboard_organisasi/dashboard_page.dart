import 'package:eventtase/dashboard_organisasi/event_card.dart';
import 'package:eventtase/dashboard_organisasi/event_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final storage = const FlutterSecureStorage();
  String organizationName = '';
  String? organizationId; 
  List<Map<String, String>> events = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizationData();
  }

  // Memuat data organisasi (termasuk organizationId) dari storage
  Future<void> _loadOrganizationData() async {
    // Baca nama organisasi
    String? name = await storage.read(key: 'organizationName');
    // Baca organizationId yang disimpan setelah registrasi
    String? id = await storage.read(key: 'organizationId');

    setState(() {
      organizationName = name ?? 'Organisasi Anda';
      organizationId = id; // Simpan organizationId yang dibaca
    });
  }

  Future<void> _logout() async {
    await storage.delete(key: 'authToken');
    await storage.delete(key: 'isOrganizationRegistered');
    await storage.delete(key: 'organizationId'); // Hapus organizationId saat logout
    Navigator.of(context).pushReplacementNamed('/welcome');
  }

  void _navigateTo(String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  // Fungsi untuk menampilkan form pembuatan event
  void _showCreateEventForm() async {
    // Pastikan organizationId ada sebelum membuka form
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

    // Jika event berhasil dibuat, tampilkan pesan sukses
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
          for (var event in events)
            EventCard(
              title: event['name']!,
              description: event['description']!,
              imagePath: event['imagePath']!,
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
