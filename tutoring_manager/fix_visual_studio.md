# Hướng dẫn sửa lỗi Visual Studio Toolchain

## Vấn đề
Khi chạy `flutter run -d windows`, gặp lỗi: 
```
Error: Unable to find suitable Visual Studio toolchain.
```

## Giải pháp

### Bước 1: Cài đặt Visual Studio Community 2022
1. Tải về Visual Studio Community 2022 từ: https://visualstudio.microsoft.com/downloads/
2. Chạy installer và chọn workload "**Desktop development with C++**"

### Bước 2: Cài đặt các component cần thiết
Đảm bảo các component sau được chọn:
- [x] **MSVC v142 - VS 2019 C++ x64/x86 build tools** (hoặc phiên bản mới nhất)
- [x] **C++ CMake tools for Windows**
- [x] **Windows 10 SDK** (hoặc Windows 11 SDK)
- [x] **C++ core features**

### Bước 3: Kiểm tra sau khi cài đặt
```bash
flutter doctor
```

Kết quả mong đợi:
```
[√] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.x.x)
```

### Bước 4: Chạy ứng dụng
```bash
cd "d:\Demo\CoHang\tutoring_manager"
flutter run -d windows
```

## Giải pháp thay thế: Chạy trên Web
Nếu không muốn cài Visual Studio, có thể chạy trên web:
```bash
flutter run -d chrome
```

## Build để phân phối
Sau khi sửa Visual Studio:
```bash
flutter build windows --release
```

File thực thi sẽ được tạo tại: `build\windows\x64\runner\Release\`
