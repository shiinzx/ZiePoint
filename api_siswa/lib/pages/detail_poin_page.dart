import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DetailPoinPage extends StatefulWidget {
  const DetailPoinPage({super.key});

  @override
  State<DetailPoinPage> createState() => _DetailPoinPageState();
}

class _DetailPoinPageState extends State<DetailPoinPage> {
  String tipe = 'pelanggaran';
  int totalPoin = 0;
  List<dynamic> _myFilteredPoints = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        tipe = args['tipe'] ?? 'pelanggaran';
        totalPoin = args['totalPoin'] ?? 0;
      });
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);
      final points = await ApiService.getMyPoints();
      
      // Filter points based on tipe
      final filtered = points.where((p) => p['tipe'] == tipe).toList();
      
      // Calculate updated total points from filtered list
      int calculatedTotal = 0;
      for (var item in filtered) {
        calculatedTotal += int.tryParse(item['poin'].toString()) ?? 0;
      }

      setState(() {
        _myFilteredPoints = filtered;
        totalPoin = calculatedTotal;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat riwayat poin")),
      );
    }
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

  Widget _buildHistoryCard(dynamic log) {
    final String jenisNama = log['jenis_nama'] ?? "-";
    final String jenisDeskripsi = log['jenis_deskripsi'] ?? "";
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

  @override
  Widget build(BuildContext context) {
    final isPelanggaran = tipe == 'pelanggaran';
    final title = isPelanggaran ? "Detail Poin Pelanggaran" : "Detail Poin Prestasi";
    final themeColor = isPelanggaran ? Theme.of(context).colorScheme.error : Colors.green.shade700;

    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Header Total Point Card
              Card(
                elevation: 0,
                color: themeColor.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: themeColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: themeColor.withOpacity(0.12),
                        child: Icon(
                          isPelanggaran ? Icons.warning_amber_rounded : Icons.emoji_events_outlined,
                          size: 36,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Poin ${isPelanggaran ? 'Pelanggaran' : 'Prestasi'}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$totalPoin Poin",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Riwayat Catatan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 12),

              _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _myFilteredPoints.isEmpty
                      ? Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Belum ada riwayat catatan ${isPelanggaran ? 'pelanggaran' : 'prestasi'}",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _myFilteredPoints.length,
                          itemBuilder: (context, index) {
                            return _buildHistoryCard(_myFilteredPoints[index]);
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
