import React, { useState, useEffect } from "react";
import TeacherModal from "../components/TeacherModal";

function Teachers({ dbManager }) {
  const [teachers, setTeachers] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingTeacher, setEditingTeacher] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [filterStatus, setFilterStatus] = useState("all");

  useEffect(() => {
    if (dbManager) {
      loadTeachers();
    }
  }, [dbManager]);

  const loadTeachers = () => {
    try {
      const teacherList = dbManager.getAllTeachers();
      setTeachers(teacherList);
    } catch (error) {
      console.error("Error loading teachers:", error);
    }
  };

  const handleAddTeacher = () => {
    setEditingTeacher(null);
    setIsModalOpen(true);
  };

  const handleEditTeacher = (teacher) => {
    setEditingTeacher(teacher);
    setIsModalOpen(true);
  };

  const handleDeleteTeacher = (id) => {
    if (window.confirm("Bạn có chắc muốn xóa giáo viên này?")) {
      try {
        dbManager.deleteTeacher(id);
        loadTeachers();
      } catch (error) {
        console.error("Error deleting teacher:", error);
        alert("Có lỗi xảy ra khi xóa giáo viên");
      }
    }
  };

  const handleSaveTeacher = (teacherData) => {
    try {
      if (editingTeacher) {
        dbManager.updateTeacher(editingTeacher.ma_giao_vien, teacherData);
      } else {
        dbManager.createTeacher(teacherData);
      }
      loadTeachers();
      setIsModalOpen(false);
    } catch (error) {
      console.error("Error saving teacher:", error);
      alert("Có lỗi xảy ra khi lưu thông tin giáo viên");
    }
  };

  const filteredTeachers = teachers.filter((teacher) => {
    const matchesSearch =
      teacher.ho_ten.toLowerCase().includes(searchTerm.toLowerCase()) ||
      teacher.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      teacher.chuyen_mon?.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesFilter =
      filterStatus === "all" ||
      (filterStatus === "active" && teacher.trang_thai) ||
      (filterStatus === "inactive" && !teacher.trang_thai);

    return matchesSearch && matchesFilter;
  });

  const formatCurrency = (amount) => {
    return amount ? `${Number(amount).toLocaleString("vi-VN")} VNĐ` : "0 VNĐ";
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString("vi-VN");
  };

  return (
    <div className="teachers-page">
      <div className="page-header">
        <div>
          <h1 className="page-title">Quản lý Giáo viên</h1>
          <p className="page-subtitle">Danh sách và thông tin giáo viên</p>
        </div>
        <button className="btn btn-primary" onClick={handleAddTeacher}>
          + Thêm giáo viên
        </button>
      </div>

      <div className="card">
        <div className="search-filter-bar">
          <input
            type="text"
            placeholder="Tìm kiếm giáo viên..."
            className="search-input"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <select
            className="filter-select"
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
          >
            <option value="all">Tất cả</option>
            <option value="active">Đang hoạt động</option>
            <option value="inactive">Không hoạt động</option>
          </select>
        </div>

        {filteredTeachers.length > 0 ? (
          <table className="table">
            <thead>
              <tr>
                <th>Họ tên</th>
                <th>Email</th>
                <th>Số điện thoại</th>
                <th>Chuyên môn</th>
                <th>Giá/giờ</th>
                <th>Kinh nghiệm</th>
                <th>Đánh giá</th>
                <th>Trạng thái</th>
                <th>Ngày tạo</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {filteredTeachers.map((teacher) => (
                <tr key={teacher.ma_giao_vien}>
                  <td>
                    <div className="teacher-name">
                      <strong>{teacher.ho_ten}</strong>
                    </div>
                  </td>
                  <td>{teacher.email}</td>
                  <td>{teacher.so_dien_thoai || "-"}</td>
                  <td>{teacher.chuyen_mon || "-"}</td>
                  <td>{formatCurrency(teacher.gia_gio)}</td>
                  <td>{teacher.kinh_nghiem} năm</td>
                  <td>
                    <div className="rating">
                      {teacher.diem_danh_gia
                        ? `${teacher.diem_danh_gia}/5`
                        : "Chưa có"}
                    </div>
                  </td>
                  <td>
                    <span
                      className={`status-badge ${
                        teacher.trang_thai ? "status-active" : "status-inactive"
                      }`}
                    >
                      {teacher.trang_thai ? "Hoạt động" : "Không hoạt động"}
                    </span>
                  </td>
                  <td>{formatDate(teacher.ngay_tao)}</td>
                  <td>
                    <div className="action-buttons">
                      <button
                        className="btn btn-secondary btn-sm"
                        onClick={() => handleEditTeacher(teacher)}
                      >
                        Sửa
                      </button>
                      <button
                        className="btn btn-danger btn-sm"
                        onClick={() =>
                          handleDeleteTeacher(teacher.ma_giao_vien)
                        }
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
            <h3>Không có giáo viên nào</h3>
            <p>Hãy thêm giáo viên đầu tiên để bắt đầu</p>
          </div>
        )}
      </div>

      {isModalOpen && (
        <TeacherModal
          teacher={editingTeacher}
          onSave={handleSaveTeacher}
          onClose={() => setIsModalOpen(false)}
        />
      )}
    </div>
  );
}

export default Teachers;
