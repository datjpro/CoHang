# Ứng dụng Quản lý Dạy Thêm

Ứng dụng desktop được phát triển bằng Flutter để quản lý các lớp dạy thêm cho giáo viên.

## Tính năng chính

### 🔐 Đăng nhập giáo viên

- Xác thực tài khoản giáo viên
- Tài khoản mặc định: `admin` / `123456`

### 📚 Quản lý lớp học

- Tạo lớp học cho các môn: Toán, Lý, Hóa, Sinh, Tiếng Anh, Văn
- Thiết lập lịch học cho mỗi lớp
- Lưu link group chat của lớp
- Sửa và xóa thông tin lớp học

### 👥 Quản lý học sinh

- Thêm học sinh vào lớp
- Thông tin chi tiết: Họ tên (riêng biệt), lớp học ở trường, số điện thoại
- Thông tin phụ huynh: Tên và số điện thoại
- Sửa và xóa thông tin học sinh

### 💾 Cơ sở dữ liệu

- Sử dụng SQLite được lưu cục bộ
- Không cần kết nối internet
- Dữ liệu được lưu an toàn trong thư mục ứng dụng

## Cài đặt và chạy

### 🚀 Cách sử dụng nhanh nhất (Đã build sẵn)

#### Option 1: Chạy file thực thi Windows

1. **Tìm file app đã build:**

   ```
   build\windows\x64\runner\Release\tutoring_manager.exe
   ```

2. **Double-click vào file .exe để chạy trực tiếp**

   - Không cần cài đặt gì thêm
   - Database sẽ được tạo tự động tại: `C:\Users\[TênBạn]\Documents\TutoringManager\`
   - Dữ liệu sẽ được lưu vĩnh viễn giữa các lần sử dụng

3. **Đăng nhập:**
   - Username: `admin`
   - Password: `123456`

#### Option 2: Chạy trên Web (Không cần build)

```bash
flutter run -d chrome
```

_Lưu ý: Dữ liệu trên web chỉ tạm thời, không được lưu vĩnh viễn_

### Yêu cầu hệ thống

- Windows 10/11 (64-bit)
- Hoặc macOS 10.14 trở lên
- Hoặc Linux (Ubuntu 18.04 trở lên)

### Chạy từ mã nguồn (Dành cho developer)

1. **Cài đặt Flutter SDK:** https://flutter.dev/docs/get-started/install
2. **Cài đặt Visual Studio Community 2022** (cho Windows):
   - Tải từ: https://visualstudio.microsoft.com/downloads/
   - Chọn workload: **"Desktop development with C++"**
   - Bao gồm: MSVC v142 build tools, C++ CMake tools, Windows 10/11 SDK
3. **Clone project và chạy:**

```bash
cd tutoring_manager
flutter pub get

# Kiểm tra thiết lập
flutter doctor

# Chạy ứng dụng
flutter run -d windows  # hoặc -d macos, -d linux

# Hoặc chạy trên web (không cần Visual Studio)
flutter run -d chrome
```

**Lưu ý:** Nếu gặp lỗi Visual Studio toolchain, xem file `fix_visual_studio.md` để biết cách khắc phục.

### Build ứng dụng để phân phối

```bash
# Build cho Windows
flutter build windows --release

# Build cho macOS
flutter build macos --release

# Build cho Linux
flutter build linux --release

# Build cho Web
flutter build web --release
```

File thực thi sẽ được tạo trong thư mục `build/`.

## 📍 Vị trí lưu trữ dữ liệu

- **Windows:** `C:\Users\[TênBạn]\Documents\TutoringManager\tutoring_manager.db`
- **macOS:** `~/Documents/TutoringManager/tutoring_manager.db`
- **Linux:** `~/Documents/TutoringManager/tutoring_manager.db`

## Cấu trúc dự án

```
lib/
├── main.dart                 # Điểm khởi đầu ứng dụng
├── models/                   # Các model dữ liệu
│   ├── teacher.dart         # Model giáo viên
│   ├── classroom.dart       # Model lớp học
│   └── student.dart         # Model học sinh & điểm danh
├── services/                # Các service
│   └── database_service.dart # Service quản lý SQLite
├── providers/               # State management
│   ├── auth_provider.dart   # Quản lý đăng nhập
│   └── classroom_provider.dart # Quản lý lớp học & học sinh
├── screens/                 # Các màn hình
│   ├── login_screen.dart    # Màn hình đăng nhập
│   └── home_screen.dart     # Màn hình chính
└── widgets/                 # Các widget tái sử dụng
    ├── classroom_form_dialog.dart # Dialog thêm/sửa lớp
    └── student_form_dialog.dart   # Dialog thêm/sửa học sinh
```

## Hướng dẫn sử dụng

### 1. Đăng nhập

- Mở ứng dụng và sử dụng tài khoản mặc định:
  - **Tên đăng nhập:** `admin`
  - **Mật khẩu:** `123456`

### 2. Quản lý lớp học

- Nhấn nút **"Thêm lớp"** để tạo lớp mới
- Điền thông tin: Tên lớp, Môn học, Lịch học, Link group chat
- Nhấn vào lớp bên trái để xem danh sách học sinh
- Sử dụng menu ⋮ để sửa, xóa hoặc mở group chat

### 3. Quản lý học sinh

- Chọn một lớp học trước
- Nhấn **"Thêm học sinh"** để thêm học sinh mới
- Điền đầy đủ thông tin cá nhân và thông tin phụ huynh
- Sử dụng menu ⋮ để sửa hoặc xóa học sinh

### 4. Tính năng khác

- **Mở group chat:** Nhấn vào menu lớp học và chọn "Mở group chat"
- **Đăng xuất:** Nhấn vào avatar góc phải và chọn "Đăng xuất"

## 💡 Tips sử dụng

- **Backup dữ liệu:** Copy thư mục `Documents\TutoringManager\` để backup
- **Khôi phục dữ liệu:** Paste lại thư mục backup để khôi phục
- **Reset app:** Xóa file `tutoring_manager.db` để reset về trạng thái ban đầu
- **Multi-platform:** App hoạt động trên Windows, macOS, Linux và Web

## Phát triển tương lai

Ứng dụng có thể mở rộng thêm các tính năng:

- ✅ Quản lý điểm danh học sinh
- ✅ Báo cáo thống kê
- ✅ Quản lý học phí
- ✅ Gửi thông báo cho phụ huynh
- ✅ Sao lưu và khôi phục dữ liệu
- ✅ In ấn báo cáo

## Hỗ trợ

Nếu gặp vấn đề hoặc cần hỗ trợ, vui lòng:

- Kiểm tra file `fix_visual_studio.md` cho các lỗi build
- Xem file `deployment_guide.md` cho hướng dẫn chi tiết
- Kiểm tra file `COMPLETION_REPORT.md` để biết tính năng đã hoàn thành

## 🎯 Status: ✅ READY FOR PRODUCTION

- ✅ **Windows Desktop:** File .exe có thể chạy trực tiếp
- ✅ **Web Browser:** Chạy demo trực tiếp bằng `flutter run -d chrome`
- ✅ **Cross-platform:** Support Windows, macOS, Linux
- ✅ **Database:** SQLite với persistent storage
- ✅ **Production ready:** Đã test và sẵn sàng sử dụng

## Bản quyền

© 2025 - Ứng dụng Quản lý Dạy Thêm
