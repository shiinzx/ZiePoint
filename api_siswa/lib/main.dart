import 'package:flutter/material.dart';
import 'pages/siswa_page.dart';
import 'pages/jenis_catatan_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const DashboardPage(), // 🔥 sekarang ke dashboard
        '/siswa': (context) => const SiswaPage(),
        '/jenis': (context) => const JenisCatatanPage(),
      },
    );
  }
}