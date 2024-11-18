import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:eventtase/dashboard_organisasi/dashboard_page.dart';
import 'package:eventtase/homeapp/event_registration_form.dart';
import 'package:eventtase/screens/welcome_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = const FlutterSecureStorage();
  bool isOrganizationRegistered = false;
  String? userId; // Simpan userId pengguna

  @override
  void initState() {
    super.initState();
    _loadUserIdAndRegistrationStatus();
  }

Future<void> _loadUserIdAndRegistrationStatus() async {
    // Ambil userId dari storage
    userId = await storage.read(key: 'userId');

    if (userId != null) {
      // Periksa status registrasi organisasi berdasarkan userId yang disimpan
      String? isRegistered = await storage.read(key: 'isOrganizationRegistered_$userId');

      setState(() {
        // Jika isRegistered == 'true', artinya organisasi sudah terdaftar
        isOrganizationRegistered = isRegistered == 'true';
        print("User ID: $userId"); // Debug log userId
        print("Organization registered status for user $userId: $isOrganizationRegistered");
      });
    } else {
      print("User ID not found.");
    }
  }


  Future<void> _refreshPage() async {
    await _loadUserIdAndRegistrationStatus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Halaman telah diperbarui!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Available Events'),
          backgroundColor: Colors.blueAccent,
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.signOutAlt),
              onPressed: () async {
                // Hapus token dan userId, tetapi simpan status registrasi organisasi
                await storage.delete(key: 'authToken');
                await storage.delete(key: 'userId');
                await storage.delete(key: 'organizationId'); 
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshPage,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return const SizedBox(); // Menampilkan card kosong
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (isOrganizationRegistered) {
                      // Arahkan ke Dashboard Admin tanpa organizationId
                      print("Navigating to Dashboard..."); // Debug log
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(),
                        ),
                      );
                    } else {
                      // Arahkan ke pendaftaran organisasi
                      print("Navigating to Event Registration Form..."); // Debug log
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EventRegistrationForm(),
                        ),
                      ).then((_) async {
                        // Periksa status lagi setelah kembali dari pendaftaran
                        await _loadUserIdAndRegistrationStatus();
                      });
                    }
                  },
                  child: Text(
                    isOrganizationRegistered ? 'Go to Dashboard' : 'Register Your Organization',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
