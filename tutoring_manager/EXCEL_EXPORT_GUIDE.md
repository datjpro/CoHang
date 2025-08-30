# Hướng Dẫn Sử Dụng Tính Năng Xuất Excel

## Tổng Quan

Ứng dụng Quản Lý Dạy Thêm hiện đã hỗ trợ xuất thông tin lớp học và danh sách học sinh ra file Excel (.xlsx) với nhiều tùy chọn khác nhau.

## Các Cách Xuất Excel

### 1. **Nút Xuất Excel Chính (Trên AppBar)**

- **Vị trí**: Góc phải trên cùng, bên cạnh menu người dùng
- **Biểu tượng**: 📥 "Xuất Excel"
- **Tùy chọn**:
  - **Xuất lớp hiện tại**: Xuất lớp đang được chọn (chỉ khả dụng khi đã chọn lớp)
  - **Xuất tất cả lớp**: Xuất toàn bộ lớp học vào một file Excel

### 2. **Nút Xuất Excel Trong Panel Lớp Học**

- **Vị trí**: Phía trên danh sách lớp học, bên cạnh nút "Thêm Lớp"
- **Chức năng**: Xuất tất cả lớp học vào một file Excel
- **Hiển thị**: Chỉ xuất hiện khi có ít nhất một lớp học

### 3. **Nút Xuất Excel Trong Panel Học Sinh**

- **Vị trí**: Phía trên danh sách học sinh, bên cạnh nút "Thêm Học Sinh"
- **Chức năng**: Xuất lớp học hiện tại cùng danh sách học sinh
- **Hiển thị**: Chỉ xuất hiện khi lớp có ít nhất một học sinh

### 4. **Menu Hành Động Của Từng Lớp**

- **Vị trí**: Nút 3 chấm dọc (⋮) ở mỗi lớp học
- **Tùy chọn**: "Xuất Excel" trong menu dropdown
- **Chức năng**: Xuất riêng lẻ lớp học đó

### 5. **Menu Người Dùng**

- **Vị trí**: Click vào avatar/tên giáo viên
- **Tùy chọn**:
  - "Xuất lớp hiện tại"
  - "Xuất tất cả lớp"

## Nội Dung File Excel

### Xuất Một Lớp Học

File Excel sẽ bao gồm:

1. **Thông tin lớp học**:

   - Tên lớp
   - Môn học
   - Link nhóm chat
   - Ngày tạo
   - Lịch học

2. **Danh sách học sinh** với các cột:

   - STT
   - Họ và tên
   - Giới tính
   - Ngày sinh
   - Lớp học (ở trường)
   - SĐT học sinh
   - Người thân
   - SĐT người thân
   - Email
   - Địa chỉ
   - Nơi sinh
   - Dân tộc
   - Ghi chú

3. **Thống kê**:
   - Tổng số học sinh
   - Số học sinh nam
   - Số học sinh nữ
   - Ngày xuất file

### Xuất Tất Cả Lớp Học

File Excel sẽ có nhiều sheet:

1. **Sheet "Tổng quan"**:

   - Danh sách tất cả lớp học
   - Thống kê cơ bản

2. **Các sheet riêng**:
   - Mỗi lớp học có một sheet riêng
   - Nội dung tương tự như xuất một lớp

## Cách Sử Dụng

1. **Chọn phương thức xuất**: Click vào một trong các nút/menu xuất Excel
2. **Chọn nơi lưu**: Hệ thống sẽ mở dialog cho phép bạn chọn thư mục và tên file
3. **Đặt tên file**: File sẽ có tên mặc định theo format:
   - Một lớp: `Lop_[TenLop]_[NgayThang].xlsx`
   - Tất cả lớp: `TatCaLopHoc_[NgayThang].xlsx`
4. **Lưu file**: Click "Save" để xuất file

## Lưu Ý

- ✅ Tính năng chỉ khả dụng khi có dữ liệu
- ✅ File Excel tương thích với Microsoft Excel và Google Sheets
- ✅ Dữ liệu được định dạng đẹp với header và màu sắc
- ✅ Tự động điều chỉnh độ rộng cột
- ✅ Hỗ trợ tiếng Việt đầy đủ

## Xử Lý Lỗi

Nếu gặp lỗi trong quá trình xuất:

- Kiểm tra quyền ghi file trong thư mục đích
- Đảm bảo không có file Excel cùng tên đang mở
- Thử lại với tên file khác
- Kiểm tra dung lượng ổ đĩa

## Hỗ Trợ

Nếu cần hỗ trợ thêm, vui lòng liên hệ hoặc báo cáo lỗi qua issue tracker.
