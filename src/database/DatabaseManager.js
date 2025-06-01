const Database = require("better-sqlite3");
const path = require("path");

class DatabaseManager {
  constructor() {
    const dbPath = path.join(__dirname, "../../data/cohang.db");
    this.db = new Database(dbPath);
    this.initTables();
  }

  initTables() {
    // Tạo bảng GIAO_VIEN
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS GIAO_VIEN (
        ma_giao_vien INTEGER PRIMARY KEY AUTOINCREMENT,
        email VARCHAR(255) UNIQUE NOT NULL,
        mat_khau VARCHAR(255) NOT NULL,
        ho_ten VARCHAR(255) NOT NULL,
        so_dien_thoai VARCHAR(20),
        dia_chi TEXT,
        chuyen_mon VARCHAR(255),
        gia_gio DECIMAL(10,2),
        kinh_nghiem INTEGER DEFAULT 0,
        diem_danh_gia DECIMAL(3,2) DEFAULT 0,
        trang_thai BOOLEAN DEFAULT 1,
        ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Tạo bảng HOC_SINH
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS HOC_SINH (
        ma_hoc_sinh INTEGER PRIMARY KEY AUTOINCREMENT,
        ho_ten VARCHAR(255) NOT NULL,
        so_dien_thoai VARCHAR(20),
        dia_chi TEXT,
        truong_hoc VARCHAR(255),
        lop VARCHAR(50),
        muc_tieu TEXT,
        ho_ten_phu_huynh VARCHAR(255),
        sdt_phu_huynh VARCHAR(20),
        ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Tạo bảng MON_HOC
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS MON_HOC (
        ma_mon_hoc INTEGER PRIMARY KEY AUTOINCREMENT,
        ten_mon_hoc VARCHAR(255) UNIQUE NOT NULL,
        mo_ta TEXT,
        trang_thai BOOLEAN DEFAULT 1,
        ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Tạo bảng KHOA_HOC
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS KHOA_HOC (
        ma_khoa_hoc INTEGER PRIMARY KEY AUTOINCREMENT,
        ma_giao_vien INTEGER NOT NULL,
        ma_mon_hoc INTEGER NOT NULL,
        ten_khoa_hoc VARCHAR(255) NOT NULL,
        mo_ta TEXT,
        gia_tien DECIMAL(10,2),
        loai_khoa_hoc VARCHAR(50) CHECK(loai_khoa_hoc IN ('ca_nhan', 'nhom', 'online')),
        trang_thai BOOLEAN DEFAULT 1,
        ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (ma_giao_vien) REFERENCES GIAO_VIEN(ma_giao_vien),
        FOREIGN KEY (ma_mon_hoc) REFERENCES MON_HOC(ma_mon_hoc)
      )
    `);

    // Tạo bảng DANG_KY
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS DANG_KY (
        ma_dang_ky INTEGER PRIMARY KEY AUTOINCREMENT,
        ma_hoc_sinh INTEGER NOT NULL,
        ma_khoa_hoc INTEGER NOT NULL,
        ngay_dang_ky DATETIME DEFAULT CURRENT_TIMESTAMP,
        trang_thai VARCHAR(50) CHECK(trang_thai IN ('cho_xac_nhan', 'da_xac_nhan', 'huy')) DEFAULT 'cho_xac_nhan',
        gia_da_thoa_thuan DECIMAL(10,2),
        ghi_chu TEXT,
        ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (ma_hoc_sinh) REFERENCES HOC_SINH(ma_hoc_sinh),
        FOREIGN KEY (ma_khoa_hoc) REFERENCES KHOA_HOC(ma_khoa_hoc)
      )
    `);

    // Tạo bảng BUOI_HOC
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS BUOI_HOC (
        ma_buoi_hoc INTEGER PRIMARY KEY AUTOINCREMENT,
        ma_khoa_hoc INTEGER NOT NULL,
        tieu_de VARCHAR(255),
        thoi_gian_hoc DATETIME,
        thoi_luong_phut INTEGER DEFAULT 90,
        trang_thai VARCHAR(50) CHECK(trang_thai IN ('chua_hoc', 'dang_hoc', 'da_hoc', 'huy')) DEFAULT 'chua_hoc',
        bai_tap TEXT,
        ghi_chu TEXT,
        ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (ma_khoa_hoc) REFERENCES KHOA_HOC(ma_khoa_hoc)
      )
    `);

    // Tạo bảng DIEM_DANH
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS DIEM_DANH (
        ma_diem_danh INTEGER PRIMARY KEY AUTOINCREMENT,
        ma_buoi_hoc INTEGER NOT NULL,
        ma_hoc_sinh INTEGER NOT NULL,
        trang_thai VARCHAR(50) CHECK(trang_thai IN ('co_mat', 'vang_mat', 'tre')) DEFAULT 'co_mat',
        gio_vao DATETIME,
        gio_ra DATETIME,
        ghi_chu TEXT,
        ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (ma_buoi_hoc) REFERENCES BUOI_HOC(ma_buoi_hoc),
        FOREIGN KEY (ma_hoc_sinh) REFERENCES HOC_SINH(ma_hoc_sinh)
      )
    `);

    // Tạo bảng THANH_TOAN
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS THANH_TOAN (
        ma_thanh_toan INTEGER PRIMARY KEY AUTOINCREMENT,
        ma_dang_ky INTEGER NOT NULL,
        so_tien DECIMAL(10,2) NOT NULL,
        ngay_thanh_toan DATETIME DEFAULT CURRENT_TIMESTAMP,
        phuong_thuc VARCHAR(50) CHECK(phuong_thuc IN ('tien_mat', 'chuyen_khoan', 'the')) DEFAULT 'tien_mat',
        trang_thai VARCHAR(50) CHECK(trang_thai IN ('thanh_cong', 'that_bai', 'cho_xac_nhan')) DEFAULT 'thanh_cong',
        ma_giao_dich VARCHAR(255),
        ghi_chu TEXT,
        ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (ma_dang_ky) REFERENCES DANG_KY(ma_dang_ky)
      )
    `);

    // Tạo bảng DANH_GIA
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS DANH_GIA (
        ma_danh_gia INTEGER PRIMARY KEY AUTOINCREMENT,
        ma_hoc_sinh INTEGER NOT NULL,
        ma_giao_vien INTEGER NOT NULL,
        ma_khoa_hoc INTEGER NOT NULL,
        diem_so INTEGER CHECK(diem_so >= 1 AND diem_so <= 5),
        nhan_xet TEXT,
        ngay_danh_gia DATETIME DEFAULT CURRENT_TIMESTAMP,
        ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (ma_hoc_sinh) REFERENCES HOC_SINH(ma_hoc_sinh),
        FOREIGN KEY (ma_giao_vien) REFERENCES GIAO_VIEN(ma_giao_vien),
        FOREIGN KEY (ma_khoa_hoc) REFERENCES KHOA_HOC(ma_khoa_hoc)
      )
    `);

    // Tạo bảng LICH_RANH
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS LICH_RANH (
        ma_lich_ranh INTEGER PRIMARY KEY AUTOINCREMENT,
        ma_giao_vien INTEGER NOT NULL,
        thu_trong_tuan INTEGER CHECK(thu_trong_tuan >= 0 AND thu_trong_tuan <= 6),
        gio_bat_dau TIME,
        gio_ket_thuc TIME,
        co_ranh BOOLEAN DEFAULT 1,
        ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (ma_giao_vien) REFERENCES GIAO_VIEN(ma_giao_vien)
      )
    `);

    console.log("Database tables created successfully!");
  }

  // CRUD cho GIAO_VIEN
  createTeacher(data) {
    const stmt = this.db.prepare(`
      INSERT INTO GIAO_VIEN (email, mat_khau, ho_ten, so_dien_thoai, dia_chi, chuyen_mon, gia_gio, kinh_nghiem)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);
    return stmt.run(
      data.email,
      data.mat_khau,
      data.ho_ten,
      data.so_dien_thoai,
      data.dia_chi,
      data.chuyen_mon,
      data.gia_gio,
      data.kinh_nghiem
    );
  }

  getAllTeachers() {
    const stmt = this.db.prepare(
      "SELECT * FROM GIAO_VIEN WHERE trang_thai = 1 ORDER BY ngay_tao DESC"
    );
    return stmt.all();
  }

  getTeacherById(id) {
    const stmt = this.db.prepare(
      "SELECT * FROM GIAO_VIEN WHERE ma_giao_vien = ?"
    );
    return stmt.get(id);
  }

  updateTeacher(id, data) {
    const stmt = this.db.prepare(`
      UPDATE GIAO_VIEN 
      SET ho_ten = ?, so_dien_thoai = ?, dia_chi = ?, chuyen_mon = ?, gia_gio = ?, kinh_nghiem = ?
      WHERE ma_giao_vien = ?
    `);
    return stmt.run(
      data.ho_ten,
      data.so_dien_thoai,
      data.dia_chi,
      data.chuyen_mon,
      data.gia_gio,
      data.kinh_nghiem,
      id
    );
  }

  deleteTeacher(id) {
    const stmt = this.db.prepare(
      "UPDATE GIAO_VIEN SET trang_thai = 0 WHERE ma_giao_vien = ?"
    );
    return stmt.run(id);
  }

  // CRUD cho HOC_SINH
  createStudent(data) {
    const stmt = this.db.prepare(`
      INSERT INTO HOC_SINH (ho_ten, so_dien_thoai, dia_chi, truong_hoc, lop, muc_tieu, ho_ten_phu_huynh, sdt_phu_huynh)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);
    return stmt.run(
      data.ho_ten,
      data.so_dien_thoai,
      data.dia_chi,
      data.truong_hoc,
      data.lop,
      data.muc_tieu,
      data.ho_ten_phu_huynh,
      data.sdt_phu_huynh
    );
  }

  getAllStudents() {
    const stmt = this.db.prepare(
      "SELECT * FROM HOC_SINH ORDER BY ngay_tao DESC"
    );
    return stmt.all();
  }

  getStudentById(id) {
    const stmt = this.db.prepare(
      "SELECT * FROM HOC_SINH WHERE ma_hoc_sinh = ?"
    );
    return stmt.get(id);
  }

  updateStudent(id, data) {
    const stmt = this.db.prepare(`
      UPDATE HOC_SINH 
      SET ho_ten = ?, so_dien_thoai = ?, dia_chi = ?, truong_hoc = ?, lop = ?, muc_tieu = ?, ho_ten_phu_huynh = ?, sdt_phu_huynh = ?
      WHERE ma_hoc_sinh = ?
    `);
    return stmt.run(
      data.ho_ten,
      data.so_dien_thoai,
      data.dia_chi,
      data.truong_hoc,
      data.lop,
      data.muc_tieu,
      data.ho_ten_phu_huynh,
      data.sdt_phu_huynh,
      id
    );
  }

  deleteStudent(id) {
    const stmt = this.db.prepare("DELETE FROM HOC_SINH WHERE ma_hoc_sinh = ?");
    return stmt.run(id);
  }

  // CRUD cho MON_HOC
  createSubject(data) {
    const stmt = this.db.prepare(
      "INSERT INTO MON_HOC (ten_mon_hoc, mo_ta) VALUES (?, ?)"
    );
    return stmt.run(data.ten_mon_hoc, data.mo_ta);
  }

  getAllSubjects() {
    const stmt = this.db.prepare(
      "SELECT * FROM MON_HOC WHERE trang_thai = 1 ORDER BY ten_mon_hoc"
    );
    return stmt.all();
  }

  // CRUD cho KHOA_HOC
  createCourse(data) {
    const stmt = this.db.prepare(`
      INSERT INTO KHOA_HOC (ma_giao_vien, ma_mon_hoc, ten_khoa_hoc, mo_ta, gia_tien, loai_khoa_hoc)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    return stmt.run(
      data.ma_giao_vien,
      data.ma_mon_hoc,
      data.ten_khoa_hoc,
      data.mo_ta,
      data.gia_tien,
      data.loai_khoa_hoc
    );
  }

  getAllCourses() {
    const stmt = this.db.prepare(`
      SELECT k.*, g.ho_ten as ten_giao_vien, m.ten_mon_hoc
      FROM KHOA_HOC k
      JOIN GIAO_VIEN g ON k.ma_giao_vien = g.ma_giao_vien
      JOIN MON_HOC m ON k.ma_mon_hoc = m.ma_mon_hoc
      WHERE k.trang_thai = 1
      ORDER BY k.ngay_tao DESC
    `);
    return stmt.all();
  }

  close() {
    this.db.close();
  }
}

module.exports = DatabaseManager;
