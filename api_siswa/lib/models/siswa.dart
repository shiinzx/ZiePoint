class Siswa {
  final int? id;
  final String nama;
  final String kelas;
  final String nis;

  Siswa({
    this.id,
    required this.nama,
    required this.kelas,
    required this.nis,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id'],
      nama: json['nama'],
      kelas: json['kelas'],
      nis: json['nis'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'kelas': kelas,
        'nis': nis,
      };
}