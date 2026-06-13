import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String id = "-";
  String nama = "-";
  String email = "-";
  String role = "-";
  String kelas = "-";

  int totalPelanggaran = 0;
  int totalPrestasi = 0;
  List<dynamic> _myPoints = [];
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
          nama = decoded['nama'] ?? "-";
          email = decoded['email'] ?? decoded['nis'] ?? decoded['nip'] ?? "-";
          role = decoded['role'] ?? "user";
          kelas = decoded['kelas'] ?? "-";
        });

        if (role == 'siswa') {
          await _loadStudentPoints();
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadStudentPoints() async {
    try {
      final points = await ApiService.getMyPoints();
      int pelanggaranSum = 0;
      int prestasiSum = 0;

      for (var item in points) {
        final tipe = item['tipe'];
        final p = int.tryParse(item['poin'].toString()) ?? 0;
        if (tipe == 'pelanggaran') {
          pelanggaranSum += p;
        } else if (tipe == 'prestasi') {
          prestasiSum += p;
        }
      }

      setState(() {
        _myPoints = points;
        totalPelanggaran = pelanggaranSum;
        totalPrestasi = prestasiSum;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat data poin")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget menu(String title, IconData icon, String route, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 44,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final isSiswa = role == 'siswa';
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                isSiswa ? Icons.person : Icons.school,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSiswa
                        ? "NIS: $email • Kelas: ${kelas.toUpperCase()}"
                        : "NIP: $email",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointSummaryCard({
    required String title,
    required int points,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Poin",
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                points.toString(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(dynamic log) {
    final String jenisNama = log['jenis_nama'] ?? "-";
    final String jenisDeskripsi = log['jenis_deskripsi'] ?? "";
    final String tipe = log['tipe'] ?? "pelanggaran";
    final int poin = int.tryParse(log['poin']?.toString() ?? '') ?? 0;
    final String keterangan = log['keterangan'] ?? "";
    final String guruNama = log['guru_nama'] ?? "Sistem";
    final String tanggalRaw = log['tanggal'] ?? "";
    final String tanggalFormatted = _formatDate(tanggalRaw);

    final isPelanggaran = tipe == 'pelanggaran';
    final color = isPelanggaran ? Theme.of(context).colorScheme.error : Colors.green.shade700;
    final pointText = isPelanggaran ? "-$poin" : "+$poin";

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.2),
        ),
      ),
      color: color.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    jenisNama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pointText,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (jenisDeskripsi.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                jenisDeskripsi,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
              ),
            ],
            const Divider(height: 20),
            if (keterangan.isNotEmpty) ...[
              Text(
                "Catatan Guru:",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                keterangan,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Oleh: $guruNama",
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  tanggalFormatted,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final year = dt.year;
      final month = dt.month.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return "$day-$month-$year $hour:$minute";
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildGuruDashboard() {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      appBar: AppBar(
        title: const Text("Dashboard Guru"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            Text(
              "Menu Utama",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  menu("Data Siswa", Icons.people, '/siswa', Colors.blue.shade700),
                  menu("Jenis Catatan", Icons.note, '/jenis', Colors.orange.shade800),
                  menu("Input Poin", Icons.add_moderator_outlined, '/input_poin', Colors.teal.shade700),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSiswaDashboard() {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      appBar: AppBar(
        title: const Text("Dashboard Siswa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadUser();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadStudentPoints();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPointSummaryCard(
                      title: "Poin Pelanggaran",
                      points: totalPelanggaran,
                      color: Theme.of(context).colorScheme.error,
                      icon: Icons.warning_amber_rounded,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detail_poin',
                          arguments: {
                            'tipe': 'pelanggaran',
                            'totalPoin': totalPelanggaran,
                          },
                        ).then((_) => loadUser());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPointSummaryCard(
                      title: "Poin Prestasi",
                      points: totalPrestasi,
                      color: Colors.green.shade700,
                      icon: Icons.emoji_events_outlined,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detail_poin',
                          arguments: {
                            'tipe': 'prestasi',
                            'totalPoin': totalPrestasi,
                          },
                        ).then((_) => loadUser());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/jenis'),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lihat Jenis Catatan",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Lihat daftar kriteria pelanggaran & prestasi",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return role == 'siswa' ? _buildSiswaDashboard() : _buildGuruDashboard();
  }
}