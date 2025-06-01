import React, { useState, useEffect } from "react";
import "./Dashboard.css";

function Dashboard() {
  const [stats, setStats] = useState({
    totalTeachers: 0,
    totalStudents: 0,
    totalCourses: 0,
    totalRevenue: 0,
  });
  const [recentActivities, setRecentActivities] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      if (window.electronAPI) {
        const [teachers, students, courses] = await Promise.all([
          window.electronAPI.getAllTeachers(),
          window.electronAPI.getAllStudents(),
          window.electronAPI.getAllCourses(),
        ]);
        setStats({
          totalTeachers: teachers.length,
          totalStudents: students.length,
          totalCourses: courses.length,
          totalRevenue: 0, // Will calculate from payments later
        });

        // Mock recent activities for now
        setRecentActivities([
          {
            id: 1,
            type: "student_registration",
            message: "Học sinh mới đăng ký khóa học Toán lớp 12",
            time: "2 giờ trước",
            icon: "👨‍🎓",
          },
          {
            id: 2,
            type: "payment",
            message: "Thanh toán học phí khóa học Vật lý",
            time: "4 giờ trước",
            icon: "💰",
          },
          {
            id: 3,
            type: "schedule",
            message: "Lịch học mới được tạo cho tuần này",
            time: "1 ngày trước",
            icon: "📅",
          },
        ]);
      }
    } catch (error) {
      console.error("Error loading dashboard data:", error);
    } finally {
      setLoading(false);
    }
  };

  const initializeSampleData = async () => {
    try {
      if (window.electronAPI) {
        await window.electronAPI.initializeSampleData();
        loadDashboardData(); // Reload data after initialization
        alert("Dữ liệu mẫu đã được khởi tạo thành công!");
      }
    } catch (error) {
      console.error("Error initializing sample data:", error);
      alert("Có lỗi xảy ra khi khởi tạo dữ liệu mẫu");
    }
  };

  const StatCard = ({ title, value, icon, color = "blue" }) => (
    <div className={`stat-card stat-card-${color}`}>
      <div className="stat-card-content">
        <div className="stat-card-info">
          <h3 className="stat-card-title">{title}</h3>
          <p className="stat-card-value">{value}</p>
        </div>
        <div className="stat-card-icon">{icon}</div>
      </div>
    </div>
  );

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h1 className="dashboard-title">Dashboard</h1>
        <p className="dashboard-subtitle">Tổng quan hệ thống quản lý dạy học</p>
        <button
          className="btn btn-secondary"
          onClick={initializeSampleData}
          style={{ marginTop: "10px" }}
        >
          Khởi tạo dữ liệu mẫu
        </button>
      </div>

      <div className="stats-grid">
        <StatCard
          title="Tổng giáo viên"
          value={stats.totalTeachers}
          icon="👨‍🏫"
          color="blue"
        />
        <StatCard
          title="Tổng học sinh"
          value={stats.totalStudents}
          icon="👨‍🎓"
          color="green"
        />
        <StatCard
          title="Khóa học"
          value={stats.totalCourses}
          icon="📚"
          color="purple"
        />
        <StatCard
          title="Doanh thu"
          value={`${stats.totalRevenue.toLocaleString("vi-VN")} VNĐ`}
          icon="💰"
          color="orange"
        />
      </div>

      <div className="dashboard-content">
        <div className="dashboard-section">
          <div className="card">
            <div className="card-header">
              <h2 className="card-title">Hoạt động gần đây</h2>
            </div>
            <div className="activities-list">
              {recentActivities.length > 0 ? (
                recentActivities.map((activity) => (
                  <div key={activity.id} className="activity-item">
                    <div className="activity-icon">{activity.icon}</div>
                    <div className="activity-content">
                      <p className="activity-message">{activity.message}</p>
                      <span className="activity-time">{activity.time}</span>
                    </div>
                  </div>
                ))
              ) : (
                <div className="empty-state">
                  <p>Chưa có hoạt động nào</p>
                </div>
              )}
            </div>
          </div>
        </div>

        <div className="dashboard-section">
          <div className="card">
            <div className="card-header">
              <h2 className="card-title">Thống kê nhanh</h2>
            </div>
            <div className="quick-stats">
              <div className="quick-stat-item">
                <div className="quick-stat-label">Buổi học hôm nay</div>
                <div className="quick-stat-value">0</div>
              </div>
              <div className="quick-stat-item">
                <div className="quick-stat-label">Học sinh vắng mặt</div>
                <div className="quick-stat-value">0</div>
              </div>
              <div className="quick-stat-item">
                <div className="quick-stat-label">Thanh toán chờ xử lý</div>
                <div className="quick-stat-value">0</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Dashboard;
