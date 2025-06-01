import React, { useState, useEffect } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";
import Sidebar from "./components/Sidebar";
import Dashboard from "./pages/Dashboard";
import Teachers from "./pages/Teachers";
import Students from "./pages/Students";
import Courses from "./pages/Courses";
import Schedule from "./pages/Schedule";
import Payments from "./pages/Payments";
import Reports from "./pages/Reports";
import DatabaseManager from "./database/DatabaseManager";

function App() {
  const [currentPage, setCurrentPage] = useState("dashboard");
  const [dbManager, setDbManager] = useState(null);

  useEffect(() => {
    // Initialize database
    try {
      const db = new DatabaseManager();
      setDbManager(db);
      console.log("Database initialized successfully");
    } catch (error) {
      console.error("Failed to initialize database:", error);
    }

    // Cleanup on unmount
    return () => {
      if (dbManager) {
        dbManager.close();
      }
    };
  }, []);

  return (
    <Router>
      <div className="app">
        <Sidebar currentPage={currentPage} setCurrentPage={setCurrentPage} />
        <div className="main-content">
          <Routes>
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
            <Route
              path="/dashboard"
              element={<Dashboard dbManager={dbManager} />}
            />
            <Route
              path="/teachers"
              element={<Teachers dbManager={dbManager} />}
            />
            <Route
              path="/students"
              element={<Students dbManager={dbManager} />}
            />
            <Route
              path="/courses"
              element={<Courses dbManager={dbManager} />}
            />
            <Route
              path="/schedule"
              element={<Schedule dbManager={dbManager} />}
            />
            <Route
              path="/payments"
              element={<Payments dbManager={dbManager} />}
            />
            <Route
              path="/reports"
              element={<Reports dbManager={dbManager} />}
            />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
