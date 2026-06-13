const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const jwt = require("jsonwebtoken");

const app = express();
app.use(cors());
app.use(express.json());

const SECRET = "SECRET_KEY_LO"; // bebas

// ================= DB =================
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "db_sekolah", // ⚠️ sesuaikan
  port: 3307, //ganti jadi 3306
});

db.connect((err) => {
  if (err) {
    console.log("❌ Database gagal konek:", err);
  } else {
    console.log("✅ Database Connected");
  }
});

// ================= REGISTER =================
app.post("/register", (req, res) => {
  const { email, password } = req.body;

  const sql = "INSERT INTO guru (email, password) VALUES (?, ?)";
  db.query(sql, [email, password], (err, result) => {
    if (err) {
      return res.status(500).json({ message: "Gagal register" });
    }
    res.json({ message: "Register berhasil" });
  });
});

// ================= LOGIN =================
app.post("/login", (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ message: "NIS/NIP dan password harus diisi" });
  }

  // 1. Coba login sebagai Guru (berdasarkan NIP)
  const sqlGuru = "SELECT * FROM guru WHERE nip = ? AND password = ?";
  db.query(sqlGuru, [username, password], (err, guruResults) => {
    if (err) return res.status(500).json({ message: "Error server" });

    if (guruResults.length > 0) {
      const user = guruResults[0];
      const token = jwt.sign(
        {
          id: user.id_guru,
          nama: user.nama,
          nip: user.nip,
          email: user.email,
          role: "guru",
        },
        SECRET,
        { expiresIn: "1h" }
      );
      return res.json({
        message: "Login Guru berhasil",
        token: token,
      });
    }

    // 2. Jika bukan guru, coba login sebagai Siswa (berdasarkan NIS)
    const sqlSiswa = "SELECT * FROM siswa WHERE nis = ? AND password = ?";
    db.query(sqlSiswa, [username, password], (err, siswaResults) => {
      if (err) return res.status(500).json({ message: "Error server" });

      if (siswaResults.length > 0) {
        const user = siswaResults[0];
        const token = jwt.sign(
          {
            id: user.id_siswa,
            nama: user.nama,
            nis: user.nis,
            kelas: user.kelas,
            role: "siswa",
          },
          SECRET,
          { expiresIn: "1h" }
        );
        return res.json({
          message: "Login Siswa berhasil",
          token: token,
        });
      }

      // 3. Jika tidak cocok di keduanya
      res.status(401).json({ message: "NIP/NIS atau password salah" });
    });
  });
});

// ================= MIDDLEWARE =================
function verifyToken(req, res, next) {
  const authHeader = req.headers["authorization"];

  if (!authHeader)
    return res.status(403).json({ message: "Token tidak ada" });

  const token = authHeader.split(" ")[1];

  jwt.verify(token, SECRET, (err, decoded) => {
    if (err) return res.status(401).json({ message: "Token tidak valid" });

    req.user = decoded;
    next();
  });
}

// ================= PROFILE =================
app.get("/profile", verifyToken, (req, res) => {
  res.json({
    message: "Berhasil ambil profile",
    user: req.user,
  });
});

// ================= GET SISWA =================
app.get("/siswa", verifyToken, (req, res) => {
  const sql = "SELECT id_siswa AS id, nama, kelas, nis FROM siswa";
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ message: "Error server" });
    res.json(results);
  });
});

// ================= ADD SISWA =================
app.post("/siswa", verifyToken, (req, res) => {
  const { nama, kelas, nis, password } = req.body;
  const pass = password || "123456";
  const sql = "INSERT INTO siswa (nama, kelas, nis, password) VALUES (?, ?, ?, ?)";
  db.query(sql, [nama, kelas, nis, pass], (err, result) => {
    if (err) return res.status(500).json({ message: "Gagal menambah siswa" });
    res.json({ message: "Berhasil menambah siswa", id: result.insertId });
  });
});

// ================= UPDATE SISWA =================
app.put("/siswa/:id", verifyToken, (req, res) => {
  const { id } = req.params;
  const { nama, kelas, nis } = req.body;
  const sql = "UPDATE siswa SET nama = ?, kelas = ?, nis = ? WHERE id_siswa = ?";
  db.query(sql, [nama, kelas, nis, id], (err, result) => {
    if (err) return res.status(500).json({ message: "Gagal mengupdate siswa" });
    res.json({ message: "Berhasil mengupdate siswa" });
  });
});

// ================= DELETE SISWA =================
app.delete("/siswa/:id", verifyToken, (req, res) => {
  const { id } = req.params;
  const sql = "DELETE FROM siswa WHERE id_siswa = ?";
  db.query(sql, [id], (err, result) => {
    if (err) return res.status(500).json({ message: "Gagal menghapus siswa" });
    res.json({ message: "Berhasil menghapus siswa" });
  });
});

// ================= GET JENIS CATATAN BY TIPE =================
app.get("/jenis_catatan/:tipe", verifyToken, (req, res) => {
  const { tipe } = req.params;
  const sql = "SELECT * FROM jenis_catatan WHERE tipe = ?";
  db.query(sql, [tipe], (err, results) => {
    if (err) return res.status(500).json({ message: "Error server" });
    res.json(results);
  });
});

// ================= TEST =================
app.get("/", (req, res) => {
  res.send("API jalan bro 🚀");
});

// ================= RUN =================
app.listen(3000, () => {
  console.log("🚀 Server jalan di http://localhost:3000");
});