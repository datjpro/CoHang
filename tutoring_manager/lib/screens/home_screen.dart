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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý dạy thêm'),
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
                                  Text('Lịch: ${classRoom.schedule}'),
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
                              : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: classRoomProvider.students.length,
                                itemBuilder: (context, index) {
                                  final student =
                                      classRoomProvider.students[index];

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green.shade600,
                                        child: Text(
                                          student.firstName[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        student.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Lớp: ${student.schoolClass}'),
                                          Text('SĐT: ${student.phone}'),
                                          Text(
                                            'Phụ huynh: ${student.parentName} - ${student.parentPhone}',
                                          ),
                                        ],
                                      ),
                                      trailing: PopupMenuButton<void>(
                                        itemBuilder:
                                            (context) => [
                                              PopupMenuItem<void>(
                                                onTap:
                                                    () =>
                                                        _showEditStudentDialog(
                                                          student,
                                                        ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Sửa'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem<void>(
                                                onTap:
                                                    () =>
                                                        _deleteStudent(student),
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
