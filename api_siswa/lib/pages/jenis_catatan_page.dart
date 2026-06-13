import 'package:flutter/material.dart';
import '../models/jenis_catatan.dart';
import '../services/api_service.dart';

class JenisCatatanPage extends StatefulWidget {
  const JenisCatatanPage({super.key});

  @override
  State<JenisCatatanPage> createState() => _JenisCatatanPageState();
}

class _JenisCatatanPageState extends State<JenisCatatanPage> {
  List<JenisCatatan> _list = [];
  String _filter = 'pelanggaran';
  bool _loading = true;

  final Color red = const Color(0xffEF4444);
  final Color green = const Color(0xff22C55E);
  final Color bg = const Color(0xffF9FAFB);

  Color get accent => _filter == 'pelanggaran' ? red : green;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() => _loading = true);
      final data = await ApiService.getByTipe(_filter);

      setState(() {
        _list = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print(e);
    }
  }

  Widget _tab(String text) {
    final active = _filter == text;
    final color = text == 'pelanggaran' ? red : green;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _filter = text);
          _load();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(JenisCatatan d) {
    final isPelanggaran = _filter == 'pelanggaran';
    final pointText = isPelanggaran ? "-${d.poin}" : "+${d.poin}";
    final color = isPelanggaran ? red : green;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          // POINT BADGE
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

          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  d.deskripsi,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        title: const Text("Jenis Catatan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TAB FILTER
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _tab("pelanggaran"),
                  _tab("prestasi"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LIST
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _list.isEmpty
                      ? const Center(child: Text("Tidak ada data"))
                      : ListView.builder(
                          itemCount: _list.length,
                          itemBuilder: (_, i) => _card(_list[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}