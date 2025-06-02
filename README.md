# Ứng dụng Quản lý Dạy thêm

Ứng dụng desktop được xây dựng bằng Flutter để quản lý các hoạt động dạy thêm, học sinh và lịch học.

## 🚀 Tính năng

- ✅ Quản lý thông tin học sinh (thêm, sửa, xóa, tìm kiếm)
- ✅ Quản lý lịch học và thời khóa biểu
- ✅ Theo dõi học phí và thanh toán
- ✅ Tạo báo cáo thống kê
- ✅ Backup và restore dữ liệu
- ✅ Giao diện thân thiện, dễ sử dụng
- ✅ Lưu trữ dữ liệu offline với SQLite

## 🛠️ Công nghệ sử dụng

- **Framework:** Flutter 3.x
- **Database:** SQLite
- **State Management:** Provider/Riverpod
- **UI Components:** Material Design 3

## 📋 Yêu cầu hệ thống

### Windows
- Windows 10 (1903) trở lên
- Visual C++ Redistributable

### macOS
- macOS 10.14 (Mojave) trở lên

### Linux
- Ubuntu 18.04 trở lên
- GTK 3.0

## 🔧 Cài đặt và chạy ứng dụng

### Cách 1: Tải file thực thi (Khuyên dùng)
1. Truy cập [Releases](https://github.com/datjpro/CoHang)
2. Tải file tương ứng với hệ điều hành:
   - Windows: `tuition-management-windows.zip`
   - macOS: `tuition-management-macos.zip`
   - Linux: `tuition-management-linux.zip`
3. Giải nén và chạy file thực thi

### Cách 2: Build từ source code

#### Yêu cầu
- Flutter SDK 3.16.0 trở lên
- Dart SDK 3.2.0 trở lên

#### Các bước thực hiện
1. **Clone repository:**
   ```bash
   git clone https://github.com/datjpro/CoHang.git
   cd tuition-management
   ```

2. **Cài đặt dependencies:**
   ```bash
   flutter pub get
   ```

3. **Chạy ứng dụng (Development):**
   ```bash
   flutter run -d windows  # Windows
   flutter run -d macos    # macOS
   flutter run -d linux    # Linux
   ```

4. **Build ứng dụng (Production):**
   ```bash
   # Windows
   flutter build windows --release
   
   # macOS
   flutter build macos --release
   
   # Linux
   flutter build linux --release
   ```

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── student.dart
│   ├── schedule.dart
│   └── payment.dart
├── services/                 # Business logic
│   ├── database_service.dart
│   ├── student_service.dart
│   └── schedule_service.dart
├── screens/                  # UI Screens
│   ├── home_screen.dart
│   ├── students_screen.dart
│   ├── schedule_screen.dart
│   └── reports_screen.dart
├── widgets/                  # Reusable widgets
│   ├── student_card.dart
│   ├── schedule_item.dart
│   └── custom_dialog.dart
└── utils/                    # Utilities
    ├── constants.dart
    ├── helpers.dart
    └── validators.dart
```

## 💾 Dữ liệu và Backup

- Dữ liệu được lưu trong file SQLite tại: `data/tuition.db`
- Backup tự động được tạo hàng ngày tại: `data/backups/`
- Có thể xuất dữ liệu ra Excel/PDF

## 🎯 Hướng dẫn sử dụng

### 1. Thêm học sinh mới
- Vào menu "Học sinh" → "Thêm mới"
- Điền đầy đủ thông tin và nhấn "Lưu"

### 2. Tạo lịch học
- Vào menu "Lịch học" → "Thêm lịch"
- Chọn học sinh, thời gian và môn học

### 3. Quản lý học phí
- Vào menu "Học phí" 
- Theo dõi các khoản đã thu và chưa thu

### 4. Xem báo cáo
- Menu "Báo cáo" hiển thị thống kê tổng quan
- Có thể xuất báo cáo ra file PDF/Excel

## 🔧 Cấu hình

Ứng dụng tự động tạo file `config.json` khi chạy lần đầu:

```json
{
  "theme": "light",
  "language": "vi",
  "autoBackup": true,
  "backupInterval": 24
}
```

## 🤝 Đóng góp

1. Fork repository này
2. Tạo feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add some amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Tạo Pull Request

## 📝 Changelog

### v1.0.0 (2025-06-02)
- ✅ Phiên bản đầu tiên
- ✅ Quản lý học sinh cơ bản
- ✅ Lịch học và thời khóa biểu
- ✅ Quản lý học phí

## 🐛 Báo lỗi

Nếu gặp lỗi hoặc có đề xuất, vui lòng tạo [Issue](https://github.com/datjpro/CoHang) mới.

## 📄 License

Dự án này được phân phối dưới giấy phép MIT. Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

## 📞 Liên hệ

- **Email:** todat2207@gmail.com
- **GitHub:** [DatjxLeon](https://github.com/datjpro)

## 🙏 Lời cảm ơn

- Flutter Team cho framework tuyệt vời
- SQLite cho database engine mạnh mẽ
- Cộng đồng Flutter Việt Nam

---

⭐ **Nếu dự án hữu ích, hãy để lại một star nhé!** ⭐
