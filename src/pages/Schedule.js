import React from "react";

function Schedule({ dbManager }) {
  return (
    <div className="schedule-page">
      <div className="page-header">
        <div>
          <h1 className="page-title">Lịch học</h1>
          <p className="page-subtitle">Quản lý lịch học và buổi học</p>
        </div>
        <button className="btn btn-primary">+ Thêm buổi học</button>
      </div>

      <div className="card">
        <div className="empty-state">
          <h3>Tính năng đang phát triển</h3>
          <p>
            Tính năng quản lý lịch học sẽ được cập nhật trong phiên bản tiếp
            theo
          </p>
        </div>
      </div>
    </div>
  );
}

export default Schedule;
