import React, { useState, useEffect } from "react";

function Courses({ dbManager }) {
  const [courses, setCourses] = useState([]);
  const [teachers, setTeachers] = useState([]);
  const [subjects, setSubjects] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    if (dbManager) {
      loadData();
    }
  }, [dbManager]);

  const loadData = () => {
    try {
      const courseList = dbManager.getAllCourses();
      const teacherList = dbManager.getAllTeachers();
      const subjectList = dbManager.getAllSubjects();

      setCourses(courseList);
      setTeachers(teacherList);
      setSubjects(subjectList);
    } catch (error) {
      console.error("Error loading courses data:", error);
    }
  };

  const filteredCourses = courses.filter((course) => {
    return (
      course.ten_khoa_hoc.toLowerCase().includes(searchTerm.toLowerCase()) ||
      course.ten_giao_vien.toLowerCase().includes(searchTerm.toLowerCase()) ||
      course.ten_mon_hoc.toLowerCase().includes(searchTerm.toLowerCase())
    );
  });

  const formatCurrency = (amount) => {
    return amount ? `${Number(amount).toLocaleString("vi-VN")} VNĐ` : "0 VNĐ";
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString("vi-VN");
  };

  const getCourseTypeLabel = (type) => {
    const types = {
      ca_nhan: "Cá nhân",
      nhom: "Nhóm",
      online: "Online",
    };
    return types[type] || type;
  };

  return (
    <div className="courses-page">
      <div className="page-header">
        <div>
          <h1 className="page-title">Quản lý Khóa học</h1>
          <p className="page-subtitle">Danh sách và thông tin khóa học</p>
        </div>
        <button className="btn btn-primary">+ Thêm khóa học</button>
      </div>

      <div className="card">
        <div className="search-filter-bar">
          <input
            type="text"
            placeholder="Tìm kiếm khóa học, giáo viên, môn học..."
            className="search-input"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>

        {filteredCourses.length > 0 ? (
          <table className="table">
            <thead>
              <tr>
                <th>Tên khóa học</th>
                <th>Giáo viên</th>
                <th>Môn học</th>
                <th>Loại khóa học</th>
                <th>Giá tiền</th>
                <th>Trạng thái</th>
                <th>Ngày tạo</th>
                <th>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {filteredCourses.map((course) => (
                <tr key={course.ma_khoa_hoc}>
                  <td>
                    <div className="course-name">
                      <strong>{course.ten_khoa_hoc}</strong>
                      {course.mo_ta && (
                        <div
                          className="course-description"
                          title={course.mo_ta}
                        >
                          {course.mo_ta.length > 50
                            ? course.mo_ta.substring(0, 50) + "..."
                            : course.mo_ta}
                        </div>
                      )}
                    </div>
                  </td>
                  <td>{course.ten_giao_vien}</td>
                  <td>{course.ten_mon_hoc}</td>
                  <td>
                    <span
                      className={`course-type course-type-${course.loai_khoa_hoc}`}
                    >
                      {getCourseTypeLabel(course.loai_khoa_hoc)}
                    </span>
                  </td>
                  <td>{formatCurrency(course.gia_tien)}</td>
                  <td>
                    <span
                      className={`status-badge ${
                        course.trang_thai ? "status-active" : "status-inactive"
                      }`}
                    >
                      {course.trang_thai ? "Hoạt động" : "Không hoạt động"}
                    </span>
                  </td>
                  <td>{formatDate(course.ngay_tao)}</td>
                  <td>
                    <div className="action-buttons">
                      <button className="btn btn-secondary btn-sm">Sửa</button>
                      <button className="btn btn-danger btn-sm">Xóa</button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <div className="empty-state">
            <h3>Không có khóa học nào</h3>
            <p>Hãy thêm khóa học đầu tiên để bắt đầu</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default Courses;
