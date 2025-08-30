import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/classroom.dart';
import '../models/student.dart';

class ExcelExportService {
  static const String _sheetName = 'Danh sách lớp học';

  /// Xuất thông tin lớp học và danh sách học sinh ra file Excel
  static Future<bool> exportClassroomData({
    required ClassRoom classroom,
    required List<Student> students,
    String? customFileName,
  }) async {
    try {
      print('Bắt đầu xuất Excel cho lớp: ${classroom.className}');
      print('Số học sinh: ${students.length}');

      // Tạo file Excel mới
      final excel = Excel.createExcel();

      // Xóa sheet mặc định
      excel.delete('Sheet1');

      // Tạo sheet cho thông tin lớp
      final sheet = excel[_sheetName];

      // Định dạng ngày tháng
      final dateFormat = DateFormat('dd/MM/yyyy');

      // Header - Thông tin lớp học
      int currentRow = 0;

      // Tiêu đề chính
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue('THÔNG TIN LỚP HỌC')
        ..cellStyle = CellStyle(
          fontSize: 16,
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: currentRow),
      );
      currentRow += 2;

      // Thông tin lớp học
      final classInfo = [
        ['Tên lớp:', classroom.className],
        ['Môn học:', classroom.subject.displayName],
        ['Link nhóm chat:', classroom.groupChatLink],
        ['Ngày tạo:', dateFormat.format(classroom.createdAt)],
        ['Lịch học:', _formatSchedule(classroom.schedule)],
      ];

      for (final info in classInfo) {
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          ..value = TextCellValue(info[0])
          ..cellStyle = CellStyle(bold: true);
        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
        )..value = TextCellValue(info[1]);
        currentRow++;
      }

      currentRow += 2;

      // Tiêu đề danh sách học sinh
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue('DANH SÁCH HỌC SINH')
        ..cellStyle = CellStyle(
          fontSize: 14,
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: currentRow),
      );
      currentRow += 2;

      // Header bảng học sinh
      final headers = [
        'STT',
        'Họ và tên',
        'Giới tính',
        'Ngày sinh',
        'Lớp học',
        'SĐT học sinh',
        'Người thân',
        'SĐT người thân',
        'Email',
        'Địa chỉ',
        'Nơi sinh',
        'Dân tộc',
        'Ghi chú',
      ];

      for (int i = 0; i < headers.length; i++) {
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow),
          )
          ..value = TextCellValue(headers[i])
          ..cellStyle = CellStyle(
            bold: true,
            backgroundColorHex: ExcelColor.fromHexString('#D3D3D3'),
            horizontalAlign: HorizontalAlign.Center,
          );
      }
      currentRow++;

      // Dữ liệu học sinh
      if (students.isNotEmpty) {
        for (int i = 0; i < students.length; i++) {
          final student = students[i];
          final rowData = [
            (i + 1).toString(),
            student.fullName,
            student.gender,
            dateFormat.format(student.dateOfBirth),
            student.schoolClass,
            student.phone ?? '',
            student.guardianName,
            student.guardianPhone,
            student.email,
            student.currentAddress,
            student.birthPlace,
            student.ethnicity,
            student.note ?? '',
          ];

          for (int j = 0; j < rowData.length; j++) {
            sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: j, rowIndex: currentRow),
            )..value = TextCellValue(rowData[j]);
          }
          currentRow++;
        }
      } else {
        // Nếu không có học sinh, thêm dòng thông báo
        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )..value = TextCellValue('Chưa có học sinh nào trong lớp này');
        currentRow++;
      }

      // Thống kê
      currentRow += 2;
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue('THỐNG KÊ')
        ..cellStyle = CellStyle(fontSize: 14, bold: true);
      currentRow++;

      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue('Tổng số học sinh:')
        ..cellStyle = CellStyle(bold: true);
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
      )..value = IntCellValue(students.length);
      currentRow++;

      // Thống kê theo giới tính
      final maleCount = students.where((s) => s.gender == 'Nam').length;
      final femaleCount = students.where((s) => s.gender == 'Nữ').length;

      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue('Học sinh nam:')
        ..cellStyle = CellStyle(bold: true);
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
      )..value = IntCellValue(maleCount);
      currentRow++;

      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue('Học sinh nữ:')
        ..cellStyle = CellStyle(bold: true);
      sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow),
      )..value = IntCellValue(femaleCount);
      currentRow++;

      // Ngày xuất
      currentRow += 2;
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue(
          'Ngày xuất: ${dateFormat.format(DateTime.now())}',
        )
        ..cellStyle = CellStyle(italic: true);

      // Tự động điều chỉnh độ rộng cột
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15.0);
      }

      // Cho phép người dùng chọn nơi lưu file
      final fileName =
          customFileName ??
          'Lop_${classroom.className.replaceAll(' ', '_')}_${DateFormat('ddMMyyyy').format(DateTime.now())}.xlsx';

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu file Excel',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        // Đảm bảo có đuôi .xlsx
        if (!outputFile.endsWith('.xlsx')) {
          outputFile = '$outputFile.xlsx';
        }

        // Lưu file
        final fileBytes = excel.save();
        if (fileBytes != null) {
          final file = File(outputFile);
          await file.writeAsBytes(fileBytes);
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Lỗi xuất Excel: $e');
      return false;
    }
  }

  /// Định dạng lịch học thành chuỗi
  static String _formatSchedule(schedule) {
    if (schedule == null) return 'Chưa có lịch học';
    if (schedule.sessions == null || schedule.sessions.isEmpty) {
      return 'Chưa có lịch học';
    }
    return schedule.toString();
  }

  /// Xuất nhiều lớp học vào các sheet khác nhau
  static Future<bool> exportMultipleClassrooms({
    required List<ClassRoom> classrooms,
    required Map<int, List<Student>> studentsMap,
    String? customFileName,
  }) async {
    try {
      final excel = Excel.createExcel();
      excel.delete('Sheet1');

      // Tạo sheet tổng quan
      final summarySheet = excel['Tổng quan'];
      int currentRow = 0;

      // Tiêu đề tổng quan
      summarySheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        )
        ..value = TextCellValue('TỔNG QUAN CÁC LỚP HỌC')
        ..cellStyle = CellStyle(
          fontSize: 16,
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
      summarySheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow),
      );
      currentRow += 2;

      // Header bảng tổng quan
      final summaryHeaders = [
        'STT',
        'Tên lớp',
        'Môn học',
        'Số học sinh',
        'Ngày tạo',
      ];
      for (int i = 0; i < summaryHeaders.length; i++) {
        summarySheet.cell(
            CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow),
          )
          ..value = TextCellValue(summaryHeaders[i])
          ..cellStyle = CellStyle(
            bold: true,
            backgroundColorHex: ExcelColor.fromHexString('#D3D3D3'),
            horizontalAlign: HorizontalAlign.Center,
          );
      }
      currentRow++;

      // Dữ liệu tổng quan
      final dateFormat = DateFormat('dd/MM/yyyy');
      for (int i = 0; i < classrooms.length; i++) {
        final classroom = classrooms[i];
        final studentCount = studentsMap[classroom.id]?.length ?? 0;

        final rowData = [
          (i + 1).toString(),
          classroom.className,
          classroom.subject.displayName,
          studentCount.toString(),
          dateFormat.format(classroom.createdAt),
        ];

        for (int j = 0; j < rowData.length; j++) {
          summarySheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: currentRow),
          )..value = TextCellValue(rowData[j]);
        }
        currentRow++;
      }

      // Tạo sheet cho từng lớp
      for (final classroom in classrooms) {
        final students = studentsMap[classroom.id] ?? [];
        final sheetName =
            classroom.className.length > 31
                ? classroom.className.substring(0, 31)
                : classroom.className;

        final classSheet = excel[sheetName];
        await _addClassroomToSheet(classSheet, classroom, students);
      }

      // Lưu file
      final fileName =
          customFileName ??
          'TatCaLopHoc_${DateFormat('ddMMyyyy').format(DateTime.now())}.xlsx';

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu file Excel',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        if (!outputFile.endsWith('.xlsx')) {
          outputFile = '$outputFile.xlsx';
        }

        final fileBytes = excel.save();
        if (fileBytes != null) {
          final file = File(outputFile);
          await file.writeAsBytes(fileBytes);
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Lỗi xuất Excel nhiều lớp: $e');
      return false;
    }
  }

  static Future<void> _addClassroomToSheet(
    Sheet sheet,
    ClassRoom classroom,
    List<Student> students,
  ) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    int currentRow = 0;

    // Thông tin lớp học
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
      ..value = TextCellValue('Lớp: ${classroom.className}')
      ..cellStyle = CellStyle(fontSize: 14, bold: true);
    currentRow += 2;

    // Header bảng học sinh
    final headers = [
      'STT',
      'Họ và tên',
      'Giới tính',
      'Ngày sinh',
      'Lớp học',
      'SĐT học sinh',
      'Người thân',
      'SĐT người thân',
      'Email',
    ];

    for (int i = 0; i < headers.length; i++) {
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow),
        )
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#D3D3D3'),
          horizontalAlign: HorizontalAlign.Center,
        );
    }
    currentRow++;

    // Dữ liệu học sinh
    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final rowData = [
        (i + 1).toString(),
        student.fullName,
        student.gender,
        dateFormat.format(student.dateOfBirth),
        student.schoolClass,
        student.phone ?? '',
        student.guardianName,
        student.guardianPhone,
        student.email,
      ];

      for (int j = 0; j < rowData.length; j++) {
        sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: currentRow),
        )..value = TextCellValue(rowData[j]);
      }
      currentRow++;
    }
  }
}
