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



  Widget _card(JenisCatatan d) {
    final isPelanggaran = _filter == 'pelanggaran';
    final pointText = isPelanggaran ? "-${d.poin}" : "+${d.poin}";
    final color = isPelanggaran
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      color: color.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // POINT BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                pointText,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d.deskripsi,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      appBar: AppBar(
        title: const Text("Jenis Catatan"),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TAB FILTER
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'pelanggaran',
                    label: Text('Pelanggaran'),
                    icon: Icon(Icons.warning_amber_rounded),
                  ),
                  ButtonSegment<String>(
                    value: 'prestasi',
                    label: Text('Prestasi'),
                    icon: Icon(Icons.emoji_events_outlined),
                  ),
                ],
                selected: <String>{_filter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _filter = newSelection.first;
                  });
                  _load();
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: _filter == 'pelanggaran'
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.primaryContainer,
                  selectedForegroundColor: _filter == 'pelanggaran'
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
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