import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/siswa.dart';
import '../services/api_service.dart';

class SiswaPage extends StatefulWidget {
  const SiswaPage({super.key});

  @override
  State<SiswaPage> createState() => _SiswaPageState();
}

class _SiswaPageState extends State<SiswaPage> {
  List<Siswa> _siswaList = [];
  bool _isLoading = true;

  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);

    final siswa = await ApiService.getSiswa();
    final prof = await ApiService.getProfile();

    setState(() {
      _siswaList = siswa;
      profile = prof;
      _isLoading = false;
    });
  }

  // 🔥 LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔥 PROFILE (INI YANG LU TANYA)
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Text(
                    "Login sebagai: ${profile?['email'] ?? '-'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: _siswaList.length,
                    itemBuilder: (_, i) {
                      final s = _siswaList[i];
                      return ListTile(
                        title: Text(s.nama),
                        subtitle: Text('${s.kelas} - ${s.nis}'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}