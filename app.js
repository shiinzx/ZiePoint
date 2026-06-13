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
  database: "api_siswa", // ⚠️ sesuaikan
  port: 3306,
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
  const { email, password } = req.body;

  const sql = "SELECT * FROM guru WHERE email = ? AND password = ?";
  db.query(sql, [email, password], (err, results) => {
    if (err) return res.status(500).json({ message: "Error server" });

    if (results.length === 0) {
      return res.status(401).json({ message: "Email atau password salah" });
    }

    const user = results[0];

    // 🔥 JWT TOKEN
    const token = jwt.sign(
      {
        id: user.id_guru,
        email: user.email,
        role: "admin",
      },
      SECRET,
      { expiresIn: "1h" }
    );

    res.json({
      message: "Login berhasil",
      token: token,
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

// ================= TEST =================
app.get("/", (req, res) => {
  res.send("API jalan bro 🚀");
});

// ================= RUN =================
app.listen(3000, () => {
  console.log("🚀 Server jalan di http://localhost:3000");
});