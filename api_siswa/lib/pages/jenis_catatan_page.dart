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
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() => _loading = true);
      final data = await ApiService.getByTipe(_filter);
      final prof = await ApiService.getProfile();

      setState(() {
        _list = data;
        profile = prof['user'];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print(e);
    }
  }

  void _showJenisDialog([JenisCatatan? jenis]) {
    final nameCtrl = TextEditingController(text: jenis?.nama ?? '');
    final descCtrl = TextEditingController(text: jenis?.deskripsi ?? '');
    final pointCtrl = TextEditingController(text: jenis?.poin.toString() ?? '');
    String selectedTipe = jenis?.tipe ?? _filter;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(jenis == null ? "Tambah Jenis Catatan" : "Edit Jenis Catatan"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Nama"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: "Deskripsi"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: pointCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Poin"),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedTipe,
                      decoration: const InputDecoration(labelText: "Tipe"),
                      items: const [
                        DropdownMenuItem(value: 'pelanggaran', child: Text('Pelanggaran')),
                        DropdownMenuItem(value: 'prestasi', child: Text('Prestasi')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedTipe = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                FilledButton(
                  onPressed: () async {
                    final points = int.tryParse(pointCtrl.text);
                    if (nameCtrl.text.isEmpty || descCtrl.text.isEmpty || points == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Harap isi semua field dengan benar")),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    setState(() => _loading = true);

                    try {
                      final item = JenisCatatan(
                        nama: nameCtrl.text,
                        deskripsi: descCtrl.text,
                        tipe: selectedTipe,
                        poin: points,
                      );

                      if (jenis == null) {
                        await ApiService.addJenisCatatan(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Berhasil menambah jenis catatan")),
                        );
                      } else {
                        await ApiService.updateJenisCatatan(jenis.id!, item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Berhasil mengubah jenis catatan")),
                        );
                      }
                      _load();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Gagal menyimpan data")),
                      );
                      setState(() => _loading = false);
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteJenis(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Jenis Catatan"),
        content: const Text("Apakah Anda yakin ingin menghapus jenis catatan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      try {
        await ApiService.deleteJenisCatatan(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil menghapus jenis catatan")),
        );
        _load();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus jenis catatan")),
        );
        setState(() => _loading = false);
      }
    }
  }

  Widget _card(JenisCatatan d) {
    final isPelanggaran = _filter == 'pelanggaran';
    final pointText = isPelanggaran ? "-${d.poin}" : "+${d.poin}";
    final color = isPelanggaran
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    final isGuru = profile?['role'] == 'guru';

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

            if (isGuru) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => _showJenisDialog(d),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Theme.of(context).colorScheme.error,
                onPressed: () => _deleteJenis(d.id!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuru = profile?['role'] == 'guru';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      appBar: AppBar(
        title: const Text("Jenis Catatan"),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
        ),
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
      floatingActionButton: isGuru
          ? FloatingActionButton(
              onPressed: () => _showJenisDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}