# Hướng dẫn Build và Phân phối Ứng dụng

## Tóm tắt Hoàn thành

✅ **Đã hoàn thành:**
- Tạo Flutter project với desktop support
- Thiết lập database SQLite với path_provider  
- Xây dựng các model dữ liệu (Teacher, ClassRoom, Student, Attendance)
- Tạo database service với CRUD operations
- Implement state management với Provider pattern
- Xây dựng UI screens (Login, Home) với Material Design 3
- Tạo form dialogs cho lớp học và học sinh
- Cài đặt validation cho form inputs
- Fix tất cả linting issues và type errors
- Database được lưu trong thư mục Documents/TutoringManager

## Cấu trúc Database

```sql
-- 4 tables với relationships
teachers (id, username, password, fullName, phone, email, createdAt)
classrooms (id, className, subject, schedule, groupChatLink, teacherId, createdAt)
students (id, firstName, lastName, schoolClass, phone, parentName, parentPhone, classRoomId, createdAt)
attendance (id, studentId, date, isPresent, note)
```

**Tài khoản mặc định:** `admin` / `123456`

## Cách chạy ứng dụng

### Option 1: Windows Desktop (Yêu cầu Visual Studio)

```bash
# Cài đặt Visual Studio Community 2022 với C++ workload
flutter run -d windows
```

### Option 2: Web Browser (Không cần Visual Studio)

```bash
flutter run -d chrome
```

### Option 3: Nền tảng khác

```bash
flutter run -d macos    # trên macOS
flutter run -d linux    # trên Linux
```

## Build cho phân phối

### Windows Executable

```bash
# Yêu cầu Visual Studio với C++ tools
flutter build windows --release

# File output: build\windows\x64\runner\Release\tutoring_manager.exe
```

### Web Deployment

```bash
flutter build web --release

# File output: build\web\
# Deploy folder này lên web server
```

### Universal Package (Tất cả platforms)

```bash
# Build cho web (không cần Visual Studio)
flutter build web --release

# Zip folder build\web\ để phân phối
```

## Tính năng đã implement

### 🔐 Authentication
- [x] Login screen với validation
- [x] Teacher authentication  
- [x] Session management

### 📚 Classroom Management
- [x] Create/Edit/Delete classrooms
- [x] Subject selection (Toán, Lý, Hóa, Sinh, Tiếng Anh, Văn)
- [x] Schedule management
- [x] Group chat links
- [x] Class selection and switching

### 👥 Student Management  
- [x] Add/Edit/Delete students
- [x] Student personal info (first/last name, school class, phone)
- [x] Parent info (name, phone)
- [x] Vietnamese phone validation
- [x] Student list per classroom

### 💾 Data Persistence
- [x] SQLite database
- [x] Local storage trong Documents/TutoringManager/
- [x] Automatic database creation
- [x] CRUD operations cho tất cả entities

### 🎨 User Interface
- [x] Material Design 3
- [x] Responsive 2-panel layout
- [x] Form validation với error messages
- [x] Context menus cho edit/delete
- [x] Professional gradient login screen
- [x] Vietnamese UI text

## Tính năng có thể mở rộng

### 📊 Attendance System
```dart
// Đã có model và database table
class Attendance {
  int? id;
  int studentId;
  DateTime date;
  bool isPresent;
  String? note;
}
```

### 💰 Fee Management
```dart
// Có thể thêm table fees
CREATE TABLE fees (
  id INTEGER PRIMARY KEY,
  studentId INTEGER,
  month INTEGER,
  year INTEGER,
  amount REAL,
  isPaid INTEGER,
  paidDate INTEGER
);
```

### 📱 Notifications
- SMS/Email notifications cho phụ huynh
- Attendance alerts
- Fee reminders

### 📈 Reports
- Attendance reports
- Fee collection reports
- Student performance tracking

## Troubleshooting

### Visual Studio Issues
```bash
# Check requirements
flutter doctor

# Fix: Install Visual Studio Community 2022
# Workload: Desktop development with C++
# Components: MSVC v142, CMake tools, Windows 10 SDK
```

### Database Issues
```bash
# Database location
Windows: C:\Users\[Username]\Documents\TutoringManager\tutoring_manager.db

# Reset database: Delete the .db file và restart app
```

### Web Compatibility
```bash
# Một số features có thể không work trên web:
# - File system access 
# - Desktop-specific APIs

# Workaround: Use web-compatible alternatives
```

## File quan trọng

- `lib/main.dart` - App entry point
- `lib/services/database_service.dart` - SQLite operations
- `lib/providers/` - State management
- `lib/screens/home_screen.dart` - Main UI
- `lib/models/` - Data models
- `pubspec.yaml` - Dependencies

## Status: ✅ READY FOR PRODUCTION

Ứng dụng đã sẵn sàng để sử dụng và phân phối. Tất cả core features đã implement và test.
