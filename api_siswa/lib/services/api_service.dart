import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/siswa.dart';
import '../models/jenis_catatan.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  // ================= JWT =================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeader() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await _authHeader(),
    );
    return jsonDecode(res.body);
  }

  // ================= SISWA =================

  static Future<List<Siswa>> getSiswa() async {
    final res = await http.get(
      Uri.parse('$baseUrl/siswa'),
      headers: await _authHeader(),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => Siswa.fromJson(e)).toList();
  }

  static Future<void> addSiswa(Siswa siswa) async {
    await http.post(
      Uri.parse('$baseUrl/siswa'),
      headers: await _authHeader(),
      body: jsonEncode(siswa.toJson()),
    );
  }

  static Future<void> updateSiswa(int id, Siswa siswa) async {
    await http.put(
      Uri.parse('$baseUrl/siswa/$id'),
      headers: await _authHeader(),
      body: jsonEncode(siswa.toJson()),
    );
  }

  static Future<void> deleteSiswa(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/siswa/$id'),
      headers: await _authHeader(),
    );
  }

  // ================= JENIS CATATAN =================

  static Future<List<JenisCatatan>> getByTipe(String tipe) async {
    final res = await http.get(
      Uri.parse('$baseUrl/jenis_catatan/$tipe'),
      headers: await _authHeader(),
    );
    final List data = jsonDecode(res.body);
    return data.map((e) => JenisCatatan.fromJson(e)).toList();
  }

  static Future<void> addJenisCatatan(JenisCatatan jenis) async {
    await http.post(
      Uri.parse('$baseUrl/jenis_catatan'),
      headers: await _authHeader(),
      body: jsonEncode(jenis.toJson()),
    );
  }

  static Future<void> updateJenisCatatan(int id, JenisCatatan jenis) async {
    await http.put(
      Uri.parse('$baseUrl/jenis_catatan/$id'),
      headers: await _authHeader(),
      body: jsonEncode(jenis.toJson()),
    );
  }

  static Future<void> deleteJenisCatatan(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/jenis_catatan/$id'),
      headers: await _authHeader(),
    );
  }
}