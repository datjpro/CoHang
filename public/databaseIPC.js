const { ipcMain } = require("electron");
const DatabaseManager = require("./database/DatabaseManager");

let dbManager;

function initDatabase() {
  try {
    dbManager = new DatabaseManager();
    console.log("Database initialized in main process");
  } catch (error) {
    console.error("Failed to initialize database:", error);
  }
}

function setupDatabaseIPC() {
  // Teachers
  ipcMain.handle("db:getAllTeachers", async () => {
    try {
      return dbManager.getAllTeachers();
    } catch (error) {
      console.error("Error getting teachers:", error);
      throw error;
    }
  });

  ipcMain.handle("db:createTeacher", async (event, teacherData) => {
    try {
      return dbManager.createTeacher(teacherData);
    } catch (error) {
      console.error("Error creating teacher:", error);
      throw error;
    }
  });

  ipcMain.handle("db:updateTeacher", async (event, id, teacherData) => {
    try {
      return dbManager.updateTeacher(id, teacherData);
    } catch (error) {
      console.error("Error updating teacher:", error);
      throw error;
    }
  });

  ipcMain.handle("db:deleteTeacher", async (event, id) => {
    try {
      return dbManager.deleteTeacher(id);
    } catch (error) {
      console.error("Error deleting teacher:", error);
      throw error;
    }
  });

  // Students
  ipcMain.handle("db:getAllStudents", async () => {
    try {
      return dbManager.getAllStudents();
    } catch (error) {
      console.error("Error getting students:", error);
      throw error;
    }
  });

  ipcMain.handle("db:createStudent", async (event, studentData) => {
    try {
      return dbManager.createStudent(studentData);
    } catch (error) {
      console.error("Error creating student:", error);
      throw error;
    }
  });

  ipcMain.handle("db:updateStudent", async (event, id, studentData) => {
    try {
      return dbManager.updateStudent(id, studentData);
    } catch (error) {
      console.error("Error updating student:", error);
      throw error;
    }
  });

  ipcMain.handle("db:deleteStudent", async (event, id) => {
    try {
      return dbManager.deleteStudent(id);
    } catch (error) {
      console.error("Error deleting student:", error);
      throw error;
    }
  });

  // Subjects
  ipcMain.handle("db:getAllSubjects", async () => {
    try {
      return dbManager.getAllSubjects();
    } catch (error) {
      console.error("Error getting subjects:", error);
      throw error;
    }
  });

  ipcMain.handle("db:createSubject", async (event, subjectData) => {
    try {
      return dbManager.createSubject(subjectData);
    } catch (error) {
      console.error("Error creating subject:", error);
      throw error;
    }
  });

  // Courses
  ipcMain.handle("db:getAllCourses", async () => {
    try {
      return dbManager.getAllCourses();
    } catch (error) {
      console.error("Error getting courses:", error);
      throw error;
    }
  });
  ipcMain.handle("db:createCourse", async (event, courseData) => {
    try {
      return dbManager.createCourse(courseData);
    } catch (error) {
      console.error("Error creating course:", error);
      throw error;
    }
  });

  ipcMain.handle("db:updateCourse", async (event, id, courseData) => {
    try {
      return dbManager.updateCourse(id, courseData);
    } catch (error) {
      console.error("Error updating course:", error);
      throw error;
    }
  });

  ipcMain.handle("db:deleteCourse", async (event, id) => {
    try {
      return dbManager.deleteCourse(id);
    } catch (error) {
      console.error("Error deleting course:", error);
      throw error;
    }
  });
  // Initialize sample data
  ipcMain.handle("db:initializeSampleData", async () => {
    try {
      return dbManager.initializeSampleData();
    } catch (error) {
      console.error("Error initializing sample data:", error);
      throw error;
    }
  });
}

function closeDatabaseConnection() {
  if (dbManager) {
    dbManager.close();
  }
}

module.exports = {
  initDatabase,
  setupDatabaseIPC,
  closeDatabaseConnection,
};
