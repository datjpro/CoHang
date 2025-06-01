import React from "react";

function Reports() {
  return (
    <div className="reports-page">
      <div className="page-header">
        <div>
          <h1 className="page-title">Báo cáo</h1>
          <p className="page-subtitle">Thống kê và báo cáo hệ thống</p>
        </div>
        <button className="btn btn-primary">Xuất báo cáo</button>
      </div>

      <div className="card">
        <div className="empty-state">
          <h3>Tính năng đang phát triển</h3>
          <p>
            Tính năng báo cáo và thống kê sẽ được cập nhật trong phiên bản tiếp
            theo
          </p>
        </div>
      </div>
    </div>
  );
}

export default Reports;
