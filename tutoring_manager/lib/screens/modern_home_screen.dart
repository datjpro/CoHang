import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../models/classroom.dart';
import '../models/student.dart';
import '../shared/widgets/app_card.dart';
import '../widgets/classroom_form_dialog.dart';
import '../widgets/student_form_dialog.dart';
import 'login_screen.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 600 && size.width <= 1200;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.secondary.withOpacity(0.02),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(context),
              Expanded(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildBody(context, isDesktop, isTablet),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.school, color: colorScheme.onPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản Lý Dạy Thêm',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Hệ thống quản lý hiện đại',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          _buildUserMenu(context),
        ],
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    authProvider.currentTeacher?.fullName
                            .substring(0, 1)
                            .toUpperCase() ??
                        'U',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      authProvider.currentTeacher?.fullName ?? '',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Giáo viên',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
          itemBuilder:
              (context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: _buildMenuItem(Icons.person, 'Thông tin cá nhân'),
                ),
                PopupMenuItem<String>(
                  value: 'debug',
                  child: _buildMenuItem(Icons.bug_report, 'Debug Database'),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: _buildMenuItem(
                    Icons.logout,
                    'Đăng xuất',
                    isDestructive: true,
                  ),
                ),
              ],
          onSelected: (value) {
            switch (value) {
              case 'debug':
                Navigator.pushNamed(context, '/debug');
                break;
              case 'logout':
                _showLogoutDialog(context);
                break;
            }
          },
        );
      },
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String text, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDestructive ? colorScheme.error : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return Row(
        children: [
          SizedBox(width: 400, child: _buildClassRoomPanel(context)),
          const VerticalDivider(width: 1),
          Expanded(child: _buildStudentPanel(context)),
        ],
      );
    } else {
      return Consumer<ClassRoomProvider>(
        builder: (context, classRoomProvider, _) {
          if (classRoomProvider.selectedClassRoom == null) {
            return _buildClassRoomPanel(context);
          } else {
            return _buildStudentPanel(context);
          }
        },
      );
    }
  }

  Widget _buildClassRoomPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lớp Học',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Quản lý các lớp học của bạn',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              _buildAddClassButton(context),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<ClassRoomProvider>(
              builder: (context, classRoomProvider, _) {
                if (classRoomProvider.isLoading) {
                  return _buildLoadingState();
                }

                if (classRoomProvider.classRooms.isEmpty) {
                  return _buildEmptyState(context);
                }

                return _buildClassRoomList(context, classRoomProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddClassButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ElevatedButton.icon(
      onPressed: _showAddClassRoomDialog,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Thêm Lớp'),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải dữ liệu...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 64,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có lớp học nào',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy tạo lớp học đầu tiên của bạn',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddClassRoomDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tạo Lớp Học'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassRoomList(BuildContext context, ClassRoomProvider provider) {
    return ListView.builder(
      itemCount: provider.classRooms.length,
      itemBuilder: (context, index) {
        final classRoom = provider.classRooms[index];
        final isSelected = provider.selectedClassRoom?.id == classRoom.id;

        return ModernCard(
          margin: const EdgeInsets.only(bottom: 16),
          isSelected: isSelected,
          onTap: () => provider.selectClassRoom(classRoom),
          leading: _buildSubjectIcon(classRoom.subject),
          title: classRoom.className,
          subtitle:
              '${classRoom.subject.displayName} • ${classRoom.schedule.toString()}',
          trailing: _buildClassRoomActions(context, classRoom),
          child: _buildClassRoomStats(context, classRoom),
        );
      },
    );
  }

  Widget _buildSubjectIcon(Subject subject) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData iconData;
    Color iconColor;

    switch (subject) {
      case Subject.math:
        iconData = Icons.calculate_rounded;
        iconColor = Colors.blue;
        break;
      case Subject.physics:
        iconData = Icons.science_rounded;
        iconColor = Colors.purple;
        break;
      case Subject.chemistry:
        iconData = Icons.biotech_rounded;
        iconColor = Colors.green;
        break;
      case Subject.biology:
        iconData = Icons.local_florist_rounded;
        iconColor = Colors.orange;
        break;
      case Subject.english:
        iconData = Icons.language_rounded;
        iconColor = Colors.red;
        break;
      case Subject.literature:
        iconData = Icons.book_rounded;
        iconColor = Colors.brown;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildClassRoomActions(BuildContext context, ClassRoom classRoom) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(
              value: 'edit',
              child: _buildMenuItem(Icons.edit, 'Chỉnh sửa'),
            ),
            if (classRoom.groupChatLink.isNotEmpty)
              PopupMenuItem<String>(
                value: 'chat',
                child: _buildMenuItem(Icons.chat, 'Mở Group Chat'),
              ),
            PopupMenuItem<String>(
              value: 'delete',
              child: _buildMenuItem(Icons.delete, 'Xóa', isDestructive: true),
            ),
          ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showEditClassRoomDialog(classRoom);
            break;
          case 'chat':
            _openGroupChat(classRoom.groupChatLink);
            break;
          case 'delete':
            _showDeleteClassDialog(context, classRoom);
            break;
        }
      },
    );
  }

  Widget _buildClassRoomStats(BuildContext context, ClassRoom classRoom) {
    return Consumer<ClassRoomProvider>(
      builder: (context, provider, _) {
        final studentCount =
            provider.selectedClassRoom?.id == classRoom.id
                ? provider.students.length
                : 0;

        return Row(
          children: [
            _buildStatItem(Icons.people, '$studentCount học sinh'),
            const SizedBox(width: 20),
            _buildStatItem(
              Icons.schedule,
              classRoom.schedule.sessions.length.toString() + ' buổi/tuần',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentPanel(BuildContext context) {
    return Consumer<ClassRoomProvider>(
      builder: (context, classRoomProvider, _) {
        if (classRoomProvider.selectedClassRoom == null) {
          return _buildSelectClassMessage(context);
        }

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentHeader(context, classRoomProvider),
              const SizedBox(height: 24),
              Expanded(
                child:
                    classRoomProvider.students.isEmpty
                        ? _buildEmptyStudentsState(context)
                        : _buildStudentList(context, classRoomProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectClassMessage(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chọn một lớp học',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn lớp học để xem danh sách học sinh',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentHeader(BuildContext context, ClassRoomProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;

    return Row(
      children: [
        if (isMobile)
          IconButton(
            onPressed: () => provider.clearSelection(),
            icon: const Icon(Icons.arrow_back),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.selectedClassRoom!.className,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${provider.selectedClassRoom!.subject.displayName} • ${provider.students.length} học sinh',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _showAddStudentDialog,
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Thêm Học Sinh'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStudentsState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có học sinh nào',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm học sinh đầu tiên vào lớp này',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddStudentDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Thêm Học Sinh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(BuildContext context, ClassRoomProvider provider) {
    return ListView.builder(
      itemCount: provider.students.length,
      itemBuilder: (context, index) {
        final student = provider.students[index];
        return ModernCard(
          margin: const EdgeInsets.only(bottom: 12),
          onTap: () => _showEditStudentDialog(student),
          leading: _buildStudentAvatar(student),
          title: student.fullName,
          subtitle: 'Lớp ${student.schoolClass} • ${student.guardianPhone}',
          trailing: _buildStudentActions(context, student),
          child: _buildStudentInfo(context, student),
        );
      },
    );
  }

  Widget _buildStudentAvatar(Student student) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CircleAvatar(
      radius: 20,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        student.firstName.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStudentActions(BuildContext context, Student student) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(
              value: 'edit',
              child: _buildMenuItem(Icons.edit, 'Chỉnh sửa'),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: _buildMenuItem(Icons.delete, 'Xóa', isDestructive: true),
            ),
          ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showEditStudentDialog(student);
            break;
          case 'delete':
            _showDeleteStudentDialog(context, student);
            break;
        }
      },
    );
  }

  Widget _buildStudentInfo(BuildContext context, Student student) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildInfoChip(
              Icons.cake,
              'Sinh ${student.dateOfBirth.day}/${student.dateOfBirth.month}/${student.dateOfBirth.year}',
            ),
            const SizedBox(width: 12),
            _buildInfoChip(
              student.gender == 'Nam' ? Icons.male : Icons.female,
              student.gender,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Phụ huynh: ${student.guardianName}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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

  void _showDeleteClassDialog(BuildContext context, ClassRoom classRoom) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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

  void _showDeleteStudentDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
}
