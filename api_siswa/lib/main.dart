import 'package:flutter/material.dart';
import 'pages/siswa_page.dart';
import 'pages/jenis_catatan_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/input_poin_page.dart';

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

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue.shade700,
          secondary: Colors.blueGrey,
          background: Colors.grey.shade50,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const DashboardPage(), // 🔥 sekarang ke dashboard
        '/siswa': (context) => const SiswaPage(),
        '/jenis': (context) => const JenisCatatanPage(),
        '/input_poin': (context) => const InputPoinPage(),
      },
    );
  }
}