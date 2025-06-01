import React, { useState, useEffect } from "react";

function StudentModal({ student, onSave, onClose }) {
  const [formData, setFormData] = useState({
    ho_ten: "",
    so_dien_thoai: "",
    dia_chi: "",
    truong_hoc: "",
    lop: "",
    muc_tieu: "",
    ho_ten_phu_huynh: "",
    sdt_phu_huynh: "",
  });

  const [errors, setErrors] = useState({});

  useEffect(() => {
    if (student) {
      setFormData({
        ho_ten: student.ho_ten || "",
        so_dien_thoai: student.so_dien_thoai || "",
        dia_chi: student.dia_chi || "",
        truong_hoc: student.truong_hoc || "",
        lop: student.lop || "",
        muc_tieu: student.muc_tieu || "",
        ho_ten_phu_huynh: student.ho_ten_phu_huynh || "",
        sdt_phu_huynh: student.sdt_phu_huynh || "",
      });
    }
  }, [student]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));

    // Clear error when user starts typing
    if (errors[name]) {
      setErrors((prev) => ({
        ...prev,
        [name]: "",
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.ho_ten.trim()) {
      newErrors.ho_ten = "Họ tên là bắt buộc";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (validateForm()) {
      onSave(formData);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal">
        <div className="modal-header">
          <h2 className="modal-title">
            {student ? "Cập nhật học sinh" : "Thêm học sinh mới"}
          </h2>
          <button className="modal-close" onClick={onClose}>
            ×
          </button>
        </div>

        <form onSubmit={handleSubmit} className="form">
          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Họ tên *</label>
              <input
                type="text"
                name="ho_ten"
                value={formData.ho_ten}
                onChange={handleChange}
                className={`form-input ${errors.ho_ten ? "error" : ""}`}
                placeholder="Nhập họ tên học sinh"
              />
              {errors.ho_ten && (
                <span className="error-text">{errors.ho_ten}</span>
              )}
            </div>

            <div className="form-group">
              <label className="form-label">Số điện thoại</label>
              <input
                type="tel"
                name="so_dien_thoai"
                value={formData.so_dien_thoai}
                onChange={handleChange}
                className="form-input"
                placeholder="Nhập số điện thoại"
              />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Địa chỉ</label>
            <textarea
              name="dia_chi"
              value={formData.dia_chi}
              onChange={handleChange}
              className="form-textarea"
              placeholder="Nhập địa chỉ"
              rows="3"
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Trường học</label>
              <input
                type="text"
                name="truong_hoc"
                value={formData.truong_hoc}
                onChange={handleChange}
                className="form-input"
                placeholder="Nhập tên trường học"
              />
            </div>

            <div className="form-group">
              <label className="form-label">Lớp</label>
              <input
                type="text"
                name="lop"
                value={formData.lop}
                onChange={handleChange}
                className="form-input"
                placeholder="Ví dụ: 12A1, Lớp 9..."
              />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Mục tiêu học tập</label>
            <textarea
              name="muc_tieu"
              value={formData.muc_tieu}
              onChange={handleChange}
              className="form-textarea"
              placeholder="Nhập mục tiêu học tập của học sinh..."
              rows="3"
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Họ tên phụ huynh</label>
              <input
                type="text"
                name="ho_ten_phu_huynh"
                value={formData.ho_ten_phu_huynh}
                onChange={handleChange}
                className="form-input"
                placeholder="Nhập họ tên phụ huynh"
              />
            </div>

            <div className="form-group">
              <label className="form-label">SĐT phụ huynh</label>
              <input
                type="tel"
                name="sdt_phu_huynh"
                value={formData.sdt_phu_huynh}
                onChange={handleChange}
                className="form-input"
                placeholder="Nhập số điện thoại phụ huynh"
              />
            </div>
          </div>

          <div className="modal-footer">
            <button
              type="button"
              className="btn btn-secondary"
              onClick={onClose}
            >
              Hủy
            </button>
            <button type="submit" className="btn btn-primary">
              {student ? "Cập nhật" : "Thêm mới"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default StudentModal;
