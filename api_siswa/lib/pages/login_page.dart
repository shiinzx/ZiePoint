import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool _loading = false;

  final Color primary = const Color(0xff2563EB);
  final Color bg = const Color(0xffF9FAFB);

  Future<void> _login() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi semua field dulu")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email.text.trim(),
          "password": password.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        // 🔥 SIMPAN TOKEN
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login berhasil")),
        );

        // 👉 pindah ke home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Login gagal")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error")),
      );
    }

    setState(() => _loading = false);
  }

  Widget _input(TextEditingController c, String hint,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _input(email, "Email"),
                _input(password, "Password", obscure: true),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Masuk"),
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