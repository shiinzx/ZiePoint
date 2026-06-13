class JenisCatatan {
  final int? id;
  final String nama;
  final String deskripsi;
  final String tipe;
  final int poin;

  JenisCatatan({
    this.id,
    required this.nama,
    required this.deskripsi,
    required this.tipe,
    required this.poin,
  });

  factory JenisCatatan.fromJson(Map<String, dynamic> json) {
    return JenisCatatan(
      id: json['id_jenis'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      tipe: json['tipe'],
      poin: json['poin'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'deskripsi': deskripsi,
        'tipe': tipe,
        'poin': poin,
      };
}