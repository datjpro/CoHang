import React, { useState, useEffect } from "react";
import StudentModal from "../components/StudentModal";

function Students() {
  const [students, setStudents] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingStudent, setEditingStudent] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadStudents();
  }, []);

  const loadStudents = async () => {
    try {
      setLoading(true);
      if (window.electronAPI) {
        const studentList = await window.electronAPI.getAllStudents();
        setStudents(studentList);
      }
    } catch (error) {
      console.error("Error loading students:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddStudent = () => {
    setEditingStudent(null);
    setIsModalOpen(true);
  };

  const handleEditStudent = (student) => {
    setEditingStudent(student);
    setIsModalOpen(true);
  };
  const handleDeleteStudent = async (id) => {
    if (window.confirm("Bạn có chắc muốn xóa học sinh này?")) {
      try {
        if (window.electronAPI) {
          await window.electronAPI.deleteStudent(id);
          loadStudents();
        }
      } catch (error) {
        console.error("Error deleting student:", error);
        alert("Có lỗi xảy ra khi xóa học sinh");
      }
    }
  };
  const handleSaveStudent = async (studentData) => {
    try {
      if (window.electronAPI) {
        if (editingStudent) {
          await window.electronAPI.updateStudent(
            editingStudent.ma_hoc_sinh,
            studentData
          );
        } else {
          await window.electronAPI.createStudent(studentData);
        }
        loadStudents();
        setIsModalOpen(false);
      }
    } catch (error) {
      console.error("Error saving student:", error);
      alert("Có lỗi xảy ra khi lưu thông tin học sinh");
    }
  };

  const filteredStudents = students.filter((student) => {
    return (
      student.ho_ten.toLowerCase().includes(searchTerm.toLowerCase()) ||
      student.truong_hoc?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      student.lop?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      student.ho_ten_phu_huynh?.toLowerCase().includes(searchTerm.toLowerCase())
    );
  });

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString("vi-VN");
  };

  return (
    <div className="students-page">
      <div className="page-header">
        <div>
          <h1 className="page-title">Quản lý Học sinh</h1>
          <p className="page-subtitle">Danh sách và thông tin học sinh</p>
        </div>
        <button className="btn btn-primary" onClick={handleAddStudent}>
          + Thêm học sinh
        </button>
      </div>

      <div className="card">
        <div className="search-filter-bar">
          <input
            type="text"
            placeholder="Tìm kiếm học sinh, trường học, lớp..."
            className="search-input"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>

        {filteredStudents.length > 0 ? (
          <table className="table">
            <thead>
              <tr>
                <th>Họ tên</th>
                <th>Trường học</th>
                <th>Lớp</th>
                <th>Số điện thoại</th>
                <th>Phụ huynh</th>
                <th>SĐT phụ huynh</th>
                <th>Mục tiêu</th>
                <th>Ngày tạo</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {filteredStudents.map((student) => (
                <tr key={student.ma_hoc_sinh}>
                  <td>
                    <div className="student-name">
                      <strong>{student.ho_ten}</strong>
                    </div>
                  </td>
                  <td>{student.truong_hoc || "-"}</td>
                  <td>{student.lop || "-"}</td>
                  <td>{student.so_dien_thoai || "-"}</td>
                  <td>{student.ho_ten_phu_huynh || "-"}</td>
                  <td>{student.sdt_phu_huynh || "-"}</td>
                  <td>
                    <div className="student-goal" title={student.muc_tieu}>
                      {student.muc_tieu
                        ? student.muc_tieu.length > 30
                          ? student.muc_tieu.substring(0, 30) + "..."
                          : student.muc_tieu
                        : "-"}
                    </div>
                  </td>
                  <td>{formatDate(student.ngay_tao)}</td>
                  <td>
                    <div className="action-buttons">
                      <button
                        className="btn btn-secondary btn-sm"
                        onClick={() => handleEditStudent(student)}
                      >
                        Sửa
                      </button>
                      <button
                        className="btn btn-danger btn-sm"
                        onClick={() => handleDeleteStudent(student.ma_hoc_sinh)}
                      >
                        Xóa
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <div className="empty-state">
            <h3>Không có học sinh nào</h3>
            <p>Hãy thêm học sinh đầu tiên để bắt đầu</p>
          </div>
        )}
      </div>

      {isModalOpen && (
        <StudentModal
          student={editingStudent}
          onSave={handleSaveStudent}
          onClose={() => setIsModalOpen(false)}
        />
      )}
    </div>
  );
}

export default Students;
