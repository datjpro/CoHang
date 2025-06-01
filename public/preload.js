const { contextBridge, ipcRenderer } = require("electron");

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld("electronAPI", {
  // Teachers
  getAllTeachers: () => ipcRenderer.invoke("db:getAllTeachers"),
  createTeacher: (teacherData) =>
    ipcRenderer.invoke("db:createTeacher", teacherData),
  updateTeacher: (id, teacherData) =>
    ipcRenderer.invoke("db:updateTeacher", id, teacherData),
  deleteTeacher: (id) => ipcRenderer.invoke("db:deleteTeacher", id),

  // Students
  getAllStudents: () => ipcRenderer.invoke("db:getAllStudents"),
  createStudent: (studentData) =>
    ipcRenderer.invoke("db:createStudent", studentData),
  updateStudent: (id, studentData) =>
    ipcRenderer.invoke("db:updateStudent", id, studentData),
  deleteStudent: (id) => ipcRenderer.invoke("db:deleteStudent", id),

  // Subjects
  getAllSubjects: () => ipcRenderer.invoke("db:getAllSubjects"),
  createSubject: (subjectData) =>
    ipcRenderer.invoke("db:createSubject", subjectData),

  // Courses
  getAllCourses: () => ipcRenderer.invoke("db:getAllCourses"),
  createCourse: (courseData) =>
    ipcRenderer.invoke("db:createCourse", courseData),
  updateCourse: (id, courseData) =>
    ipcRenderer.invoke("db:updateCourse", id, courseData),
  deleteCourse: (id) => ipcRenderer.invoke("db:deleteCourse", id),

  // Schedules
  getAllSchedules: () => ipcRenderer.invoke("db:getAllSchedules"),
  createSchedule: (scheduleData) =>
    ipcRenderer.invoke("db:createSchedule", scheduleData),
  updateSchedule: (id, scheduleData) =>
    ipcRenderer.invoke("db:updateSchedule", id, scheduleData),
  deleteSchedule: (id) => ipcRenderer.invoke("db:deleteSchedule", id),

  // Attendance
  getAllAttendance: () => ipcRenderer.invoke("db:getAllAttendance"),
  createAttendance: (attendanceData) =>
    ipcRenderer.invoke("db:createAttendance", attendanceData),
  updateAttendance: (id, attendanceData) =>
    ipcRenderer.invoke("db:updateAttendance", id, attendanceData),

  // Payments
  getAllPayments: () => ipcRenderer.invoke("db:getAllPayments"),
  createPayment: (paymentData) =>
    ipcRenderer.invoke("db:createPayment", paymentData),
  updatePayment: (id, paymentData) =>
    ipcRenderer.invoke("db:updatePayment", id, paymentData),

  // Evaluations
  getAllEvaluations: () => ipcRenderer.invoke("db:getAllEvaluations"),
  createEvaluation: (evaluationData) =>
    ipcRenderer.invoke("db:createEvaluation", evaluationData),
  updateEvaluation: (id, evaluationData) =>
    ipcRenderer.invoke("db:updateEvaluation", id, evaluationData),

  // Dashboard/Statistics
  getDashboardStats: () => ipcRenderer.invoke("db:getDashboardStats"),
  getAttendanceStats: () => ipcRenderer.invoke("db:getAttendanceStats"),
  getPaymentStats: () => ipcRenderer.invoke("db:getPaymentStats"),

  // Sample data
  initializeSampleData: () => ipcRenderer.invoke("db:initializeSampleData"),
});
