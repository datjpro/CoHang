import React, { useState, useEffect } from "react";

function TeacherModal({ teacher, onSave, onClose }) {
  const [formData, setFormData] = useState({
    email: "",
    mat_khau: "",
    ho_ten: "",
    so_dien_thoai: "",
    dia_chi: "",
    chuyen_mon: "",
    gia_gio: "",
    kinh_nghiem: 0,
  });

  const [errors, setErrors] = useState({});

  useEffect(() => {
    if (teacher) {
      setFormData({
        email: teacher.email || "",
        mat_khau: "", // Don't prefill password for security
        ho_ten: teacher.ho_ten || "",
        so_dien_thoai: teacher.so_dien_thoai || "",
        dia_chi: teacher.dia_chi || "",
        chuyen_mon: teacher.chuyen_mon || "",
        gia_gio: teacher.gia_gio || "",
        kinh_nghiem: teacher.kinh_nghiem || 0,
      });
    }
  }, [teacher]);

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

    if (!formData.email.trim()) {
      newErrors.email = "Email là bắt buộc";
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = "Email không hợp lệ";
    }

    if (!teacher && !formData.mat_khau.trim()) {
      newErrors.mat_khau = "Mật khẩu là bắt buộc";
    }

    if (formData.gia_gio && isNaN(formData.gia_gio)) {
      newErrors.gia_gio = "Giá giờ phải là số";
    }

    if (formData.kinh_nghiem && isNaN(formData.kinh_nghiem)) {
      newErrors.kinh_nghiem = "Kinh nghiệm phải là số";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (validateForm()) {
      // Convert numeric fields
      const submitData = {
        ...formData,
        gia_gio: formData.gia_gio ? parseFloat(formData.gia_gio) : 0,
        kinh_nghiem: formData.kinh_nghiem ? parseInt(formData.kinh_nghiem) : 0,
      };

      // Don't include password if it's empty (for updates)
      if (teacher && !submitData.mat_khau) {
        delete submitData.mat_khau;
      }

      onSave(submitData);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal">
        <div className="modal-header">
          <h2 className="modal-title">
            {teacher ? "Cập nhật giáo viên" : "Thêm giáo viên mới"}
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
                placeholder="Nhập họ tên"
              />
              {errors.ho_ten && (
                <span className="error-text">{errors.ho_ten}</span>
              )}
            </div>

            <div className="form-group">
              <label className="form-label">Email *</label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                className={`form-input ${errors.email ? "error" : ""}`}
                placeholder="Nhập email"
              />
              {errors.email && (
                <span className="error-text">{errors.email}</span>
              )}
            </div>
          </div>

          {!teacher && (
            <div className="form-group">
              <label className="form-label">Mật khẩu *</label>
              <input
                type="password"
                name="mat_khau"
                value={formData.mat_khau}
                onChange={handleChange}
                className={`form-input ${errors.mat_khau ? "error" : ""}`}
                placeholder="Nhập mật khẩu"
              />
              {errors.mat_khau && (
                <span className="error-text">{errors.mat_khau}</span>
              )}
            </div>
          )}

          <div className="form-row">
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

            <div className="form-group">
              <label className="form-label">Chuyên môn</label>
              <input
                type="text"
                name="chuyen_mon"
                value={formData.chuyen_mon}
                onChange={handleChange}
                className="form-input"
                placeholder="Ví dụ: Toán, Lý, Hóa..."
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
              <label className="form-label">Giá giờ (VNĐ)</label>
              <input
                type="number"
                name="gia_gio"
                value={formData.gia_gio}
                onChange={handleChange}
                className={`form-input ${errors.gia_gio ? "error" : ""}`}
                placeholder="0"
                min="0"
                step="1000"
              />
              {errors.gia_gio && (
                <span className="error-text">{errors.gia_gio}</span>
              )}
            </div>

            <div className="form-group">
              <label className="form-label">Kinh nghiệm (năm)</label>
              <input
                type="number"
                name="kinh_nghiem"
                value={formData.kinh_nghiem}
                onChange={handleChange}
                className={`form-input ${errors.kinh_nghiem ? "error" : ""}`}
                placeholder="0"
                min="0"
              />
              {errors.kinh_nghiem && (
                <span className="error-text">{errors.kinh_nghiem}</span>
              )}
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
              {teacher ? "Cập nhật" : "Thêm mới"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default TeacherModal;
