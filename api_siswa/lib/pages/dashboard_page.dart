import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String id = "-";
  String email = "-";
  String role = "-";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        Map<String, dynamic> decoded = JwtDecoder.decode(token);

        setState(() {
          id = decoded['id'].toString();
          email = decoded['email'] ?? "-";
          role = decoded['role'] ?? "user";
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget menu(String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xff2563EB)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),

      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 DATA USER DARI JWT
                  Text("ID: $id"),
                  Text("Email: $email"),
                  Text("Role: $role"),

                  const SizedBox(height: 20),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        menu("Data Siswa", Icons.people, '/siswa'),
                        menu("Jenis Catatan", Icons.note, '/jenis'),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}