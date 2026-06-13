import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/siswa.dart';
import '../services/api_service.dart';

class SiswaPage extends StatefulWidget {
  const SiswaPage({super.key});

  @override
  State<SiswaPage> createState() => _SiswaPageState();
}

class _SiswaPageState extends State<SiswaPage> {
  List<Siswa> _siswaList = [];
  bool _isLoading = true;

  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);

    final siswa = await ApiService.getSiswa();
    final prof = await ApiService.getProfile();

    setState(() {
      _siswaList = siswa;
      profile = prof['user'];
      _isLoading = false;
    });
  }

  // 🔥 LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showSiswaDialog([Siswa? siswa]) {
    final nameCtrl = TextEditingController(text: siswa?.nama ?? '');
    final classCtrl = TextEditingController(text: siswa?.kelas ?? '');
    final nisCtrl = TextEditingController(text: siswa?.nis ?? '');
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(siswa == null ? "Tambah Siswa" : "Edit Siswa"),
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
                  controller: classCtrl,
                  decoration: const InputDecoration(labelText: "Kelas"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nisCtrl,
                  decoration: const InputDecoration(labelText: "NIS"),
                ),
                if (siswa == null) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password (Opsional)",
                      hintText: "Default: 123456",
                    ),
                  ),
                ],
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
                if (nameCtrl.text.isEmpty || classCtrl.text.isEmpty || nisCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Harap isi semua field")),
                  );
                  return;
                }
                Navigator.pop(context);
                setState(() => _isLoading = true);

                try {
                  if (siswa == null) {
                    await ApiService.addSiswa(Siswa(
                      nama: nameCtrl.text,
                      kelas: classCtrl.text,
                      nis: nisCtrl.text,
                      password: passCtrl.text.isNotEmpty ? passCtrl.text : null,
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berhasil menambah siswa")),
                    );
                  } else {
                    await ApiService.updateSiswa(
                      siswa.id!,
                      Siswa(
                        nama: nameCtrl.text,
                        kelas: classCtrl.text,
                        nis: nisCtrl.text,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Berhasil mengubah data siswa")),
                    );
                  }
                  _loadAll();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal menyimpan data")),
                  );
                  setState(() => _isLoading = false);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSiswa(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Siswa"),
        content: const Text("Apakah Anda yakin ingin menghapus data siswa ini?"),
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
      setState(() => _isLoading = true);
      try {
        await ApiService.deleteSiswa(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil menghapus siswa")),
        );
        _loadAll();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus siswa")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuru = profile?['role'] == 'guru';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 0,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.person_pin,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      "Login sebagai: ${profile?['email'] ?? profile?['nis'] ?? profile?['nip'] ?? '-'}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    subtitle: Text(
                      "Role: ${profile?['role']?.toString().toUpperCase() ?? '-'}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: _siswaList.length,
                    itemBuilder: (_, i) {
                      final s = _siswaList[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              s.nama.isNotEmpty ? s.nama[0].toUpperCase() : 'S',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            s.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${s.kelas.toUpperCase()} • NIS: ${s.nis}'),
                          trailing: isGuru
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20),
                                      color: Theme.of(context).colorScheme.primary,
                                      onPressed: () => _showSiswaDialog(s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                      color: Theme.of(context).colorScheme.error,
                                      onPressed: () => _deleteSiswa(s.id!),
                                    ),
                                  ],
                                )
                              : Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: isGuru
          ? FloatingActionButton(
              onPressed: () => _showSiswaDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}