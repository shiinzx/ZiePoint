class Siswa {
  final int? id;
  final String nama;
  final String kelas;
  final String nis;
  final String? password;

  Siswa({
    this.id,
    required this.nama,
    required this.kelas,
    required this.nis,
    this.password,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id'],
      nama: json['nama'],
      kelas: json['kelas'],
      nis: json['nis'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{
      'nama': nama,
      'kelas': kelas,
      'nis': nis,
    };
    if (password != null) {
      val['password'] = password;
    }
    return val;
  }
}