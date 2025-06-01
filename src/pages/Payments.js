import React from "react";

function Payments() {
  return (
    <div className="payments-page">
      <div className="page-header">
        <div>
          <h1 className="page-title">Thanh toán</h1>
          <p className="page-subtitle">Quản lý thanh toán và học phí</p>
        </div>
        <button className="btn btn-primary">+ Thêm thanh toán</button>
      </div>

      <div className="card">
        <div className="empty-state">
          <h3>Tính năng đang phát triển</h3>
          <p>
            Tính năng quản lý thanh toán sẽ được cập nhật trong phiên bản tiếp
            theo
          </p>
        </div>
      </div>
    </div>
  );
}

export default Payments;
