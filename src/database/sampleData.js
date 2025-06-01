// Sample data initialization for testing
const DatabaseManager = require("./DatabaseManager");

function initSampleData() {
  const db = new DatabaseManager();

  try {
    // Add sample subjects
    const subjects = [
      {
        ten_mon_hoc: "Toán học",
        mo_ta: "Môn toán các cấp từ tiểu học đến THPT",
      },
      { ten_mon_hoc: "Vật lý", mo_ta: "Vật lý THCS và THPT" },
      { ten_mon_hoc: "Hóa học", mo_ta: "Hóa học THCS và THPT" },
      { ten_mon_hoc: "Tiếng Anh", mo_ta: "Tiếng Anh giao tiếp và học thuật" },
      { ten_mon_hoc: "Văn học", mo_ta: "Ngữ văn các cấp" },
    ];

    subjects.forEach((subject) => {
      try {
        db.createSubject(subject);
      } catch (error) {
        // Subject might already exist
      }
    });

    // Add sample teachers
    const teachers = [
      {
        email: "teacher1@cohang.com",
        mat_khau: "123456",
        ho_ten: "Nguyễn Văn An",
        so_dien_thoai: "0901234567",
        dia_chi: "Hà Nội",
        chuyen_mon: "Toán học",
        gia_gio: 200000,
        kinh_nghiem: 5,
      },
      {
        email: "teacher2@cohang.com",
        mat_khau: "123456",
        ho_ten: "Trần Thị Bình",
        so_dien_thoai: "0907654321",
        dia_chi: "Hồ Chí Minh",
        chuyen_mon: "Vật lý",
        gia_gio: 250000,
        kinh_nghiem: 7,
      },
    ];

    teachers.forEach((teacher) => {
      try {
        db.createTeacher(teacher);
      } catch (error) {
        // Teacher might already exist
      }
    });

    // Add sample students
    const students = [
      {
        ho_ten: "Lê Minh Tâm",
        so_dien_thoai: "0981234567",
        dia_chi: "Quận 1, Hồ Chí Minh",
        truong_hoc: "THPT Lê Quý Đôn",
        lop: "12A1",
        muc_tieu: "Đậu đại học",
        ho_ten_phu_huynh: "Lê Văn Nam",
        sdt_phu_huynh: "0909876543",
      },
      {
        ho_ten: "Phạm Thu Hà",
        so_dien_thoai: "0987654321",
        dia_chi: "Cầu Giấy, Hà Nội",
        truong_hoc: "THCS Chu Văn An",
        lop: "9A2",
        muc_tieu: "Nâng cao điểm số",
        ho_ten_phu_huynh: "Phạm Minh Đức",
        sdt_phu_huynh: "0912345678",
      },
    ];

    students.forEach((student) => {
      try {
        db.createStudent(student);
      } catch (error) {
        // Student might already exist
      }
    });

    console.log("Sample data initialized successfully");
    db.close();
  } catch (error) {
    console.error("Error initializing sample data:", error);
    db.close();
  }
}

module.exports = { initSampleData };
