import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../models/classroom.dart';
import '../models/student.dart';
import '../shared/widgets/responsive_layout.dart';
import '../shared/widgets/app_card.dart';
import '../shared/widgets/app_button.dart';
import '../shared/extensions/context_extensions.dart';
import '../widgets/classroom_form_dialog.dart';
import '../widgets/student_form_dialog.dart';
import 'login_screen.dart';

class ImprovedHomeScreen extends StatefulWidget {
  const ImprovedHomeScreen({super.key});

  @override
  State<ImprovedHomeScreen> createState() => _ImprovedHomeScreenState();
}

class _ImprovedHomeScreenState extends State<ImprovedHomeScreen> {
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

  void _logout() async {
    final result = await context.showDeleteConfirmDialog(
      title: 'Đăng xuất',
      content: 'Bạn có chắc chắn muốn đăng xuất?',
    );
    
    if (result == true && mounted) {
      Provider.of<AuthProvider>(context, listen: false).logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
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
    final selectedClassRoom = Provider.of<ClassRoomProvider>(
      context,
      listen: false,
    ).selectedClassRoom;
    
    if (selectedClassRoom != null) {
      showDialog(
        context: context,
        builder: (context) => StudentFormDialog(classRoomId: selectedClassRoom.id!),
      );
    }
  }

  void _showEditStudentDialog(Student student) {
    showDialog(
      context: context,
      builder: (context) => StudentFormDialog(
        classRoomId: student.classRoomId,
        student: student,
      ),
    );
  }

  void _deleteClassRoom(ClassRoom classRoom) async {
    final result = await context.showDeleteConfirmDialog(
      title: 'Xóa lớp học',
      content: 'Bạn có chắc chắn muốn xóa lớp "${classRoom.className}"?',
    );
    
    if (result == true && mounted) {
      try {
        await Provider.of<ClassRoomProvider>(context, listen: false)
            .deleteClassRoom(classRoom.id!);
        if (mounted) {
          context.showSuccessSnackBar('Xóa lớp học thành công!');
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar('Có lỗi xảy ra khi xóa lớp học');
        }
      }
    }
  }

  void _deleteStudent(Student student) async {
    final result = await context.showDeleteConfirmDialog(
      title: 'Xóa học sinh',
      content: 'Bạn có chắc chắn muốn xóa học sinh "${student.fullName}"?',
    );
    
    if (result == true && mounted) {
      try {
        await Provider.of<ClassRoomProvider>(context, listen: false)
            .deleteStudent(student.id!);
        if (mounted) {
          context.showSuccessSnackBar('Xóa học sinh thành công!');
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar('Có lỗi xảy ra khi xóa học sinh');
        }
      }
    }
  }

  Future<void> _openGroupChat(String url) async {
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) {
            context.showErrorSnackBar('Không thể mở link group chat');
          }
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar('Link không hợp lệ');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý dạy thêm'),
        centerTitle: false,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<void>(
                icon: CircleAvatar(
                  backgroundColor: context.colorScheme.primary,
                  child: Text(
                    (authProvider.currentTeacher?.fullName ?? 'U')[0].toUpperCase(),
                    style: TextStyle(
                      color: context.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem<void>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.currentTeacher?.fullName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          authProvider.currentTeacher?.email ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colorScheme.onSurfaceVariant,
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
                        Icon(Icons.logout, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Consumer<ClassRoomProvider>(
      builder: (context, classRoomProvider, _) {
        if (classRoomProvider.selectedClassRoom == null) {
          return _buildClassRoomsList();
        }
        return _buildStudentsList();
      },
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        SizedBox(
          width: 350,
          child: _buildClassRoomsList(),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _buildStudentsList()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: _buildClassRoomsList(),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _buildStudentsList()),
      ],
    );
  }

  Widget _buildClassRoomsList() {
    return Consumer<ClassRoomProvider>(
      builder: (context, classRoomProvider, _) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: context.colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Danh sách lớp học',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AppButton(
                    text: 'Thêm lớp',
                    icon: Icons.add,
                    onPressed: _showAddClassRoomDialog,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.small,
                  ),
                ],
              ),
            ),
            
            // Loading state
            if (classRoomProvider.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            
            // Empty state
            else if (classRoomProvider.classRooms.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có lớp học nào',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hãy tạo lớp học đầu tiên của bạn',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            
            // Class rooms list
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classRoomProvider.classRooms.length,
                  itemBuilder: (context, index) {
                    final classRoom = classRoomProvider.classRooms[index];
                    final isSelected = classRoomProvider.selectedClassRoom?.id == classRoom.id;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () => classRoomProvider.selectClassRoom(classRoom),
                        backgroundColor: isSelected 
                            ? context.colorScheme.primaryContainer
                            : null,
                        border: isSelected 
                            ? Border.all(color: context.colorScheme.primary, width: 2)
                            : null,
                        leading: CircleAvatar(
                          backgroundColor: context.colorScheme.primary,
                          child: Text(
                            classRoom.subject.displayName[0],
                            style: TextStyle(
                              color: context.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: classRoom.className,
                        subtitle: '${classRoom.subject.displayName} • ${classRoom.schedule}',
                        trailing: PopupMenuButton<void>(
                          itemBuilder: (context) => [
                            PopupMenuItem<void>(
                              onTap: () => _showEditClassRoomDialog(classRoom),
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
                                onTap: () => _openGroupChat(classRoom.groupChatLink),
                                child: const Row(
                                  children: [
                                    Icon(Icons.chat, size: 18),
                                    SizedBox(width: 8),
                                    Text('Mở group chat'),
                                  ],
                                ),
                              ),
                            PopupMenuItem<void>(
                              onTap: () => _deleteClassRoom(classRoom),
                              child: const Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Xóa', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        child: const SizedBox.shrink(),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStudentsList() {
    return Consumer<ClassRoomProvider>(
      builder: (context, classRoomProvider, _) {
        if (classRoomProvider.selectedClassRoom == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back,
                  size: 64,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chọn một lớp học để xem danh sách học sinh',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: context.colorScheme.surface,
              child: Row(
                children: [
                  if (context.isMobile) ...[
                    IconButton(
                      onPressed: () {
                        classRoomProvider.deselectClassRoom();
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classRoomProvider.selectedClassRoom!.className,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          classRoomProvider.selectedClassRoom!.subject.displayName,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    text: 'Thêm học sinh',
                    icon: Icons.person_add,
                    onPressed: _showAddStudentDialog,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.small,
                  ),
                ],
              ),
            ),
            
            // Students content
            Expanded(
              child: classRoomProvider.students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có học sinh nào',
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy thêm học sinh đầu tiên cho lớp này',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ResponsiveBuilder(
                      builder: (context, deviceType) {
                        if (deviceType == DeviceType.mobile) {
                          return _buildStudentsCards(classRoomProvider.students);
                        } else {
                          return _buildStudentsTable(classRoomProvider.students);
                        }
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStudentsCards(List<Student> students) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            leading: CircleAvatar(
              backgroundColor: context.colorScheme.secondary,
              child: Text(
                student.firstName[0].toUpperCase(),
                style: TextStyle(
                  color: context.colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: student.fullName,
            subtitle: 'Lớp ${student.schoolClass} • ${student.gender}',
            trailing: PopupMenuButton<void>(
              itemBuilder: (context) => [
                PopupMenuItem<void>(
                  onTap: () => _showEditStudentDialog(student),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Sửa'),
                    ],
                  ),
                ),
                PopupMenuItem<void>(
                  onTap: () => _deleteStudent(student),
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (student.phone != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        student.phone!,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        student.guardianName,
                        style: context.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsTable(List<Student> students) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AppCard.header(
        title: 'Danh sách học sinh (${students.length})',
        leading: Icon(
          Icons.table_view,
          color: context.colorScheme.primary,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('STT')),
              DataColumn(label: Text('Họ và tên đệm')),
              DataColumn(label: Text('Tên')),
              DataColumn(label: Text('Giới tính')),
              DataColumn(label: Text('Ngày sinh')),
              DataColumn(label: Text('Lớp')),
              DataColumn(label: Text('SĐT học sinh')),
              DataColumn(label: Text('Người thân')),
              DataColumn(label: Text('SĐT người thân')),
              DataColumn(label: Text('Thao tác')),
            ],
            rows: students.asMap().entries.map((entry) {
              final index = entry.key;
              final student = entry.value;
              
              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(student.lastName)),
                  DataCell(Text(student.firstName)),
                  DataCell(Text(student.gender)),
                  DataCell(Text(
                    '${student.dateOfBirth.day.toString().padLeft(2, '0')}/'
                    '${student.dateOfBirth.month.toString().padLeft(2, '0')}/'
                    '${student.dateOfBirth.year}'
                  )),
                  DataCell(Text(student.schoolClass)),
                  DataCell(Text(student.phone ?? '')),
                  DataCell(Text(student.guardianName)),
                  DataCell(Text(student.guardianPhone)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          onPressed: () => _showEditStudentDialog(student),
                          tooltip: 'Sửa',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                          onPressed: () => _deleteStudent(student),
                          tooltip: 'Xóa',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
