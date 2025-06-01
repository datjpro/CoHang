import React from "react";
import { useLocation, useNavigate } from "react-router-dom";
import "./Sidebar.css";

function Sidebar({ currentPage, setCurrentPage }) {
  const location = useLocation();
  const navigate = useNavigate();

  const menuItems = [
    {
      id: "dashboard",
      label: "Dashboard",
      icon: "📊",
      path: "/dashboard",
    },
    {
      id: "teachers",
      label: "Giáo viên",
      icon: "👨‍🏫",
      path: "/teachers",
    },
    {
      id: "students",
      label: "Học sinh",
      icon: "👨‍🎓",
      path: "/students",
    },
    {
      id: "courses",
      label: "Khóa học",
      icon: "📚",
      path: "/courses",
    },
    {
      id: "schedule",
      label: "Lịch học",
      icon: "📅",
      path: "/schedule",
    },
    {
      id: "payments",
      label: "Thanh toán",
      icon: "💰",
      path: "/payments",
    },
    {
      id: "reports",
      label: "Báo cáo",
      icon: "📈",
      path: "/reports",
    },
  ];

  const handleMenuClick = (item) => {
    setCurrentPage(item.id);
    navigate(item.path);
  };

  return (
    <div className="sidebar">
      <div className="sidebar-header">
        <h2 className="sidebar-title">
          <span className="sidebar-icon">🎓</span>
          CoHang
        </h2>
        <p className="sidebar-subtitle">Quản lý dạy học</p>
      </div>

      <nav className="sidebar-nav">
        <ul className="sidebar-menu">
          {menuItems.map((item) => (
            <li key={item.id} className="sidebar-menu-item">
              <button
                className={`sidebar-menu-button ${
                  location.pathname === item.path ? "active" : ""
                }`}
                onClick={() => handleMenuClick(item)}
              >
                <span className="sidebar-menu-icon">{item.icon}</span>
                <span className="sidebar-menu-label">{item.label}</span>
              </button>
            </li>
          ))}
        </ul>
      </nav>

      <div className="sidebar-footer">
        <div className="sidebar-user">
          <div className="sidebar-user-avatar">👤</div>
          <div className="sidebar-user-info">
            <div className="sidebar-user-name">Admin</div>
            <div className="sidebar-user-role">Quản trị viên</div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Sidebar;
