import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../models/classroom.dart';
import '../models/student.dart';
import 'login_screen.dart';
import '../widgets/classroom_form_dialog.dart';
import '../widgets/student_form_dialog.dart';

class HomeScreenImproved extends StatefulWidget {
  const HomeScreenImproved({super.key});

  @override
  State<HomeScreenImproved> createState() => _HomeScreenImprovedState();
}

class _HomeScreenImprovedState extends State<HomeScreenImproved> {
  Map<int, Map<String, bool>> _editing = {};
  Map<int, Map<String, TextEditingController>> _controllers = {};
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentTeacher != null) {
        Provider.of<ClassRoomProvider>(
          context,
          listen: false,
        ).loadClassRooms(authProvider.currentTeacher!.id!);
      }
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showAddClassRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => const ClassRoomFormDialog(),
    );
  }

  void _showEditClassRoomDialog(ClassRoom classRoom) {
    showDialog(
      context: context,
      builder: (context) => ClassRoomFormDialog(classRoom: classRoom),
    );
  }

  void _showAddStudentDialog() {
    final selectedClassRoom =
        Provider.of<ClassRoomProvider>(
          context,
          listen: false,
        ).selectedClassRoom;
    if (selectedClassRoom != null) {
      showDialog(
        context: context,
        builder:
            (context) => StudentFormDialog(classRoomId: selectedClassRoom.id!),
      );
    }
  }

  void _showEditStudentDialog(Student student) {
    showDialog(
      context: context,
      builder:
          (context) => StudentFormDialog(
            classRoomId: student.classRoomId,
            student: student,
          ),
    );
  }

  void _deleteClassRoom(ClassRoom classRoom) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa lớp học'),
            content: Text(
              'Bạn có chắc chắn muốn xóa lớp "${classRoom.className}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<ClassRoomProvider>(
                    context,
                    listen: false,
                  ).deleteClassRoom(classRoom.id!);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _deleteStudent(Student student) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa học sinh'),
            content: Text(
              'Bạn có chắc chắn muốn xóa học sinh "${student.fullName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<ClassRoomProvider>(
                    context,
                    listen: false,
                  ).deleteStudent(student.id!);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  Future<void> _openGroupChat(String url) async {
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể mở link group chat')),
          );
        }
      }
    }
  }

  void _startEdit(int studentId, String field, String initialValue) {
    setState(() {
      _editing[studentId] ??= {};
      _editing[studentId]![field] = true;
      _controllers[studentId] ??= {};
      _controllers[studentId]![field] = TextEditingController(
        text: initialValue,
      );
    });
  }

  void _saveEdit(
    int studentId,
    String field,
    Student student,
    ClassRoomProvider provider,
  ) async {
    final value = _controllers[studentId]?[field]?.text ?? '';
    Student updated = student;
    switch (field) {
      case 'lastName':
        updated = student.copyWith(lastName: value);
        break;
      case 'firstName':
        updated = student.copyWith(firstName: value);
        break;
      case 'gender':
        updated = student.copyWith(gender: value);
        break;
      case 'dateOfBirth':
        try {
          final parts = value.split('/');
          if (parts.length == 3) {
            final d = int.parse(parts[0]);
            final m = int.parse(parts[1]);
            final y = int.parse(parts[2]);
            updated = student.copyWith(dateOfBirth: DateTime(y, m, d));
          }
        } catch (_) {}
        break;
      case 'birthPlace':
        updated = student.copyWith(birthPlace: value);
        break;
      case 'currentAddress':
        updated = student.copyWith(currentAddress: value);
        break;
      case 'schoolClass':
        updated = student.copyWith(schoolClass: value);
        break;
      case 'phone':
        updated = student.copyWith(phone: value.isEmpty ? null : value);
        break;
      case 'guardianName':
        updated = student.copyWith(guardianName: value);
        break;
      case 'guardianPhone':
        updated = student.copyWith(guardianPhone: value);
        break;
      case 'email':
        updated = student.copyWith(email: value);
        break;
      case 'note':
        updated = student.copyWith(note: value);
        break;
      default:
        break;
    }
    await provider.updateStudent(updated);
    setState(() {
      _editing[studentId]?[field] = false;
    });
  }

  Widget _editableCell({
    required int studentId,
    required String field,
    required String value,
    required Student student,
    required ClassRoomProvider provider,
    bool isDropdown = false,
    List<String>? dropdownItems,
    double? width,
  }) {
    if (_editing[studentId]?[field] == true) {
      if (isDropdown && dropdownItems != null) {
        return DropdownButton<String>(
          value: _controllers[studentId]![field]!.text,
          items:
              dropdownItems
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
          onChanged: (val) {
            if (val != null) {
              _controllers[studentId]![field]!.text = val;
              _saveEdit(studentId, field, student, provider);
            }
          },
        );
      }
      return SizedBox(
        width: width ?? 120,
        child: TextField(
          controller: _controllers[studentId]![field],
          autofocus: true,
          onSubmitted: (_) => _saveEdit(studentId, field, student, provider),
          onEditingComplete:
              () => _saveEdit(studentId, field, student, provider),
          onTapOutside: (_) => _saveEdit(studentId, field, student, provider),
        ),
      );
    }
    return InkWell(
      onTap: () => _startEdit(studentId, field, value),
      child: Container(
        width: width ?? 120,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(
          value.isEmpty ? '...' : value,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý dạy thêm - Cải tiến'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<void>(
                icon: const Icon(Icons.account_circle),
                itemBuilder:
                    (context) => [
                      PopupMenuItem<void>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.currentTeacher?.fullName ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              authProvider.currentTeacher?.email ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<void>(
                        onTap: () => Navigator.pushNamed(context, '/debug'),
                        child: const Row(
                          children: [
                            Icon(Icons.bug_report, size: 18),
                            SizedBox(width: 8),
                            Text('Database Debug'),
                          ],
                        ),
                      ),
                      PopupMenuItem<void>(
                        onTap: _logout,
                        child: const Row(
                          children: [
                            Icon(Icons.logout, size: 18),
                            SizedBox(width: 8),
                            Text('Đăng xuất'),
                          ],
                        ),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left panel - ClassRooms list
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Danh sách lớp học',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddClassRoomDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Thêm lớp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<ClassRoomProvider>(
                    builder: (context, classRoomProvider, _) {
                      if (classRoomProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (classRoomProvider.classRooms.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.school, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có lớp học nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: classRoomProvider.classRooms.length,
                        itemBuilder: (context, index) {
                          final classRoom = classRoomProvider.classRooms[index];
                          final isSelected =
                              classRoomProvider.selectedClassRoom?.id ==
                              classRoom.id;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: isSelected ? 4 : 1,
                            color: isSelected ? Colors.blue.shade50 : null,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade600,
                                child: Text(
                                  classRoom.subject.displayName[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                classRoom.className,
                                style: TextStyle(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Môn: ${classRoom.subject.displayName}'),
                                  Text(
                                    'Lịch: ${classRoom.schedule.toString()}',
                                  ),
                                ],
                              ),
                              onTap:
                                  () => classRoomProvider.selectClassRoom(
                                    classRoom,
                                  ),
                              trailing: PopupMenuButton<void>(
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem<void>(
                                        onTap:
                                            () => _showEditClassRoomDialog(
                                              classRoom,
                                            ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.edit, size: 18),
                                            SizedBox(width: 8),
                                            Text('Sửa'),
                                          ],
                                        ),
                                      ),
                                      if (classRoom.groupChatLink.isNotEmpty)
                                        PopupMenuItem<void>(
                                          onTap:
                                              () => _openGroupChat(
                                                classRoom.groupChatLink,
                                              ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.chat, size: 18),
                                              SizedBox(width: 8),
                                              Text('Mở group chat'),
                                            ],
                                          ),
                                        ),
                                      PopupMenuItem<void>(
                                        onTap:
                                            () => _deleteClassRoom(classRoom),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Xóa',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Right panel - Students list
          Expanded(
            child: Consumer<ClassRoomProvider>(
              builder: (context, classRoomProvider, _) {
                if (classRoomProvider.selectedClassRoom == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Chọn một lớp học để xem danh sách học sinh',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lớp: ${classRoomProvider.selectedClassRoom!.className}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Môn: ${classRoomProvider.selectedClassRoom!.subject.displayName}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddStudentDialog,
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Thêm học sinh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          classRoomProvider.students.isEmpty
                              ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Chưa có học sinh nào trong lớp này',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Enhanced scrollable table container
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: Column(
                                          children: [
                                            // Enhanced table header with scroll info
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade50,
                                                    Colors.blue.shade100,
                                                  ],
                                                ),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        8,
                                                      ),
                                                      topRight: Radius.circular(
                                                        8,
                                                      ),
                                                    ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.table_view,
                                                    size: 18,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Danh sách học sinh (${classRoomProvider.students.length} học sinh)',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color:
                                                          Colors.blue.shade800,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.blue.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.swap_horiz,
                                                          size: 16,
                                                          color:
                                                              Colors
                                                                  .blue
                                                                  .shade700,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Kéo để xem thêm thông tin',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors
                                                                    .blue
                                                                    .shade700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ), // Scrollable table
                                            Expanded(
                                              child: Scrollbar(
                                                controller:
                                                    _horizontalScrollController,
                                                thumbVisibility: true,
                                                thickness: 8,
                                                child: SingleChildScrollView(
                                                  controller:
                                                      _horizontalScrollController,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Scrollbar(
                                                    controller:
                                                        _verticalScrollController,
                                                    thumbVisibility: true,
                                                    thickness: 8,
                                                    child: SingleChildScrollView(
                                                      controller:
                                                          _verticalScrollController,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      child: ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                              minWidth:
                                                                  MediaQuery.of(
                                                                    context,
                                                                  ).size.width -
                                                                  400,
                                                            ),
                                                        child: DataTable(
                                                          headingRowColor:
                                                              MaterialStateProperty.all(
                                                                Colors
                                                                    .blue
                                                                    .shade50,
                                                              ),
                                                          border: TableBorder.all(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                          ),
                                                          columnSpacing: 12,
                                                          horizontalMargin: 8,
                                                          dataRowMinHeight: 52,
                                                          dataRowMaxHeight: 72,
                                                          headingRowHeight: 56,
                                                          columns: const [
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 40,
                                                                child: Text(
                                                                  'STT',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 120,
                                                                child: Text(
                                                                  'Họ và tên đệm',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 80,
                                                                child: Text(
                                                                  'Tên',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 70,
                                                                child: Text(
                                                                  'Giới tính',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 90,
                                                                child: Text(
                                                                  'Ngày sinh',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 100,
                                                                child: Text(
                                                                  'Nơi sinh',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 150,
                                                                child: Text(
                                                                  'Địa chỉ hiện tại',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 60,
                                                                child: Text(
                                                                  'Lớp',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 100,
                                                                child: Text(
                                                                  'SĐT học sinh',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 120,
                                                                child: Text(
                                                                  'Người thân',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 110,
                                                                child: Text(
                                                                  'SĐT người thân',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 120,
                                                                child: Text(
                                                                  'Email',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 100,
                                                                child: Text(
                                                                  'Ghi chú',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: 80,
                                                                child: Text(
                                                                  'Thao tác',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                          rows:
                                                              classRoomProvider.students.asMap().entries.map((
                                                                entry,
                                                              ) {
                                                                final index =
                                                                    entry.key;
                                                                final student =
                                                                    entry.value;
                                                                final id =
                                                                    student.id!;
                                                                return DataRow(
                                                                  color: MaterialStateProperty.resolveWith<
                                                                    Color?
                                                                  >((
                                                                    Set<
                                                                      MaterialState
                                                                    >
                                                                    states,
                                                                  ) {
                                                                    if (index %
                                                                            2 ==
                                                                        0)
                                                                      return Colors
                                                                          .grey
                                                                          .shade50;
                                                                    return null;
                                                                  }),
                                                                  cells: [
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            40,
                                                                        child: Container(
                                                                          padding: const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                4,
                                                                            horizontal:
                                                                                8,
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.blue.shade100,
                                                                            borderRadius: BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                          ),
                                                                          child: Text(
                                                                            '${index + 1}',
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  12,
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                              color:
                                                                                  Colors.blue.shade700,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            120,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'lastName',
                                                                          value:
                                                                              student.lastName,
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              120,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            80,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'firstName',
                                                                          value:
                                                                              student.firstName,
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              80,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            70,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'gender',
                                                                          value:
                                                                              student.gender,
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          isDropdown:
                                                                              true,
                                                                          dropdownItems: [
                                                                            'Nam',
                                                                            'Nữ',
                                                                            'Khác',
                                                                          ],
                                                                          width:
                                                                              70,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            90,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'dateOfBirth',
                                                                          value:
                                                                              '${student.dateOfBirth.day.toString().padLeft(2, '0')}/'
                                                                              '${student.dateOfBirth.month.toString().padLeft(2, '0')}/'
                                                                              '${student.dateOfBirth.year}',
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              90,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            100,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'birthPlace',
                                                                          value:
                                                                              student.birthPlace,
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              100,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            150,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'currentAddress',
                                                                          value:
                                                                              student.currentAddress,
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              150,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            60,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'schoolClass',
                                                                          value:
                                                                              student.schoolClass,
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              60,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            100,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'phone',
                                                                          value:
                                                                              student.phone ??
                                                                              '',
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              100,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            120,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'guardianName',
                                                                          value:
                                                                              student.guardianName,
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              120,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            110,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'guardianPhone',
                                                                          value:
                                                                              student.guardianPhone,
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              110,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            120,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'email',
                                                                          value:
                                                                              student.email,
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              120,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            100,
                                                                        child: _editableCell(
                                                                          studentId:
                                                                              id,
                                                                          field:
                                                                              'note',
                                                                          value:
                                                                              student.note ??
                                                                              '',
                                                                          student:
                                                                              student,
                                                                          provider:
                                                                              classRoomProvider,
                                                                          width:
                                                                              100,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      SizedBox(
                                                                        width:
                                                                            80,
                                                                        child: Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            IconButton(
                                                                              icon: const Icon(
                                                                                Icons.edit,
                                                                                size:
                                                                                    16,
                                                                              ),
                                                                              onPressed:
                                                                                  () => _showEditStudentDialog(
                                                                                    student,
                                                                                  ),
                                                                              tooltip:
                                                                                  'Sửa',
                                                                              padding:
                                                                                  EdgeInsets.zero,
                                                                              constraints: const BoxConstraints(
                                                                                minWidth:
                                                                                    32,
                                                                                minHeight:
                                                                                    32,
                                                                              ),
                                                                            ),
                                                                            IconButton(
                                                                              icon: const Icon(
                                                                                Icons.delete,
                                                                                size:
                                                                                    16,
                                                                                color:
                                                                                    Colors.red,
                                                                              ),
                                                                              onPressed:
                                                                                  () => _deleteStudent(
                                                                                    student,
                                                                                  ),
                                                                              tooltip:
                                                                                  'Xóa',
                                                                              padding:
                                                                                  EdgeInsets.zero,
                                                                              constraints: const BoxConstraints(
                                                                                minWidth:
                                                                                    32,
                                                                                minHeight:
                                                                                    32,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
