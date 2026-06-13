import 'package:flutter/material.dart';
import '../models/siswa.dart';
import '../models/jenis_catatan.dart';
import '../services/api_service.dart';

class InputPoinPage extends StatefulWidget {
  const InputPoinPage({super.key});

  @override
  State<InputPoinPage> createState() => _InputPoinPageState();
}

class _InputPoinPageState extends State<InputPoinPage> {
  List<Siswa> _siswaList = [];
  List<JenisCatatan> _jenisList = [];
  bool _loading = true;

  int? _selectedSiswaId;
  int? _selectedJenisId;
  final _keteranganCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);
      final siswa = await ApiService.getSiswa();
      final jenis = await ApiService.getAllJenisCatatan();

      setState(() {
        _siswaList = siswa;
        _jenisList = jenis;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat data")),
      );
    }
  }

  Future<void> _submit() async {
    if (_selectedSiswaId == null || _selectedJenisId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih siswa dan jenis catatan")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ApiService.inputPoinSiswa(
        _selectedSiswaId!,
        _selectedJenisId!,
        _keteranganCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil menyimpan poin siswa")),
      );

      setState(() {
        _selectedSiswaId = null;
        _selectedJenisId = null;
        _keteranganCtrl.clear();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan poin")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Input Poin Siswa"),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Form Input Poin",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // DROPDOWN SISWA
                      DropdownButtonFormField<int>(
                        value: _selectedSiswaId,
                        decoration: InputDecoration(
                          labelText: "Pilih Siswa",
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _siswaList.map((s) {
                          return DropdownMenuItem<int>(
                            value: s.id,
                            child: Text("${s.nama} (${s.kelas.toUpperCase()})"),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSiswaId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // DROPDOWN JENIS CATATAN
                      DropdownButtonFormField<int>(
                        value: _selectedJenisId,
                        decoration: InputDecoration(
                          labelText: "Pilih Jenis Catatan / Poin",
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: _jenisList.map((j) {
                          final pointSign = j.tipe == 'pelanggaran' ? "-" : "+";
                          return DropdownMenuItem<int>(
                            value: j.id,
                            child: Text("${j.nama} ($pointSign${j.poin} Poin)"),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedJenisId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // KETERANGAN
                      TextField(
                        controller: _keteranganCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Keterangan / Catatan Tambahan (Opsional)",
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Simpan Poin",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
