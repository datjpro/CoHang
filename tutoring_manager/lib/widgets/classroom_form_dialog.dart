import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/classroom.dart';
import '../models/schedule.dart';
import '../providers/classroom_provider.dart';
import '../providers/auth_provider.dart';
import 'schedule_selector.dart';

class ClassRoomFormDialog extends StatefulWidget {
  final ClassRoom? classRoom;

  const ClassRoomFormDialog({super.key, this.classRoom});

  bool get isEdit => classRoom != null;

  @override
  State<ClassRoomFormDialog> createState() => _ClassRoomFormDialogState();
}

class _ClassRoomFormDialogState extends State<ClassRoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _classNameController;
  late TextEditingController _groupChatLinkController;
  Subject? _selectedSubject;
  late ClassSchedule _schedule;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(
      text: widget.classRoom?.className ?? '',
    );
    _groupChatLinkController = TextEditingController(
      text: widget.classRoom?.groupChatLink ?? '',
    );
    _selectedSubject = widget.classRoom?.subject;
    _schedule = widget.classRoom?.schedule ?? const ClassSchedule(sessions: []);
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _groupChatLinkController.dispose();
    super.dispose();
  }

  bool _hasScheduleConflict(ClassSchedule schedule) {
    final sessions = schedule.sessions;
    final conflictGroups = <String, List<int>>{};

    // Nhóm các session theo day + time
    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final key = '${session.dayOfWeek.name}_${session.timeSlot.name}';
      conflictGroups.putIfAbsent(key, () => []).add(i);
    }

    // Kiểm tra có nhóm nào có nhiều hơn 1 session
    return conflictGroups.values.any((indices) => indices.length > 1);
  }

  void _save() async {
    if (_formKey.currentState!.validate() &&
        _selectedSubject != null &&
        _schedule.sessions.isNotEmpty) {
      // Kiểm tra trùng lịch
      if (_hasScheduleConflict(_schedule)) {
        _showErrorSnackBar(
          'Lịch học có xung đột! Vui lòng kiểm tra lại thời gian và ngày học.',
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final classRoomProvider = Provider.of<ClassRoomProvider>(
          context,
          listen: false,
        );

        final classRoom = ClassRoom(
          id: widget.classRoom?.id,
          className: _classNameController.text.trim(),
          subject: _selectedSubject!,
          schedule: _schedule,
          groupChatLink: _groupChatLinkController.text.trim(),
          teacherId: authProvider.currentTeacher!.id!,
          createdAt: widget.classRoom?.createdAt ?? DateTime.now(),
        );

        if (widget.isEdit) {
          await classRoomProvider.updateClassRoom(classRoom);
        } else {
          await classRoomProvider.addClassRoom(classRoom);
        }

        if (mounted) {
          Navigator.of(context).pop();
          _showSuccessSnackBar(
            widget.isEdit
                ? 'Cập nhật lớp học thành công!'
                : 'Thêm lớp học thành công!',
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Có lỗi xảy ra. Vui lòng thử lại!');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (_schedule.sessions.isEmpty) {
      _showErrorSnackBar('Vui lòng thêm ít nhất một buổi học');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        width:
            MediaQuery.of(context).size.width > 600
                ? 600
                : MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Modern Header with gradient
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.isEdit
                                ? Icons.edit_rounded
                                : Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isEdit
                                    ? 'Chỉnh sửa lớp học'
                                    : 'Tạo lớp học mới',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.isEdit
                                    ? 'Cập nhật thông tin lớp học của bạn'
                                    : 'Điền thông tin để tạo lớp học mới',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                          tooltip: 'Đóng',
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content with improved design
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Information Card
                          _buildSectionCard(
                            icon: Icons.info_outline_rounded,
                            title: 'Thông tin cơ bản',
                            children: [
                              _buildTextField(
                                controller: _classNameController,
                                label: 'Tên lớp học',
                                hint: 'Ví dụ: Toán 10A, Lý 12B...',
                                icon: Icons.class_rounded,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập tên lớp học';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildSubjectDropdown(),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Schedule Card
                          _buildSectionCard(
                            icon: Icons.schedule_rounded,
                            title: 'Lịch học',
                            children: [
                              ScheduleSelector(
                                initialSchedule: _schedule,
                                onScheduleChanged: (newSchedule) {
                                  setState(() {
                                    _schedule = newSchedule;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Additional Information Card
                          _buildSectionCard(
                            icon: Icons.link_rounded,
                            title: 'Thông tin bổ sung',
                            children: [
                              _buildTextField(
                                controller: _groupChatLinkController,
                                label: 'Link nhóm chat',
                                hint: 'https://...',
                                icon: Icons.chat_bubble_outline_rounded,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (!value.startsWith('http://') &&
                                        !value.startsWith('https://')) {
                                      return 'Link phải bắt đầu với http:// hoặc https://';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Modern Footer with better buttons
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: colorScheme.outline),
                            ),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child:
                                _isLoading
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  colorScheme.onPrimary,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Đang xử lý...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          widget.isEdit
                                              ? Icons.update_rounded
                                              : Icons.add_rounded,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.isEdit
                                              ? 'Cập nhật'
                                              : 'Tạo lớp học',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSubjectDropdown() {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<Subject>(
      value: _selectedSubject,
      decoration: InputDecoration(
        labelText: 'Môn học',
        prefixIcon: Icon(Icons.subject_rounded, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      items:
          Subject.values.map((subject) {
            return DropdownMenuItem(
              value: subject,
              child: Row(
                children: [
                  _getSubjectIcon(subject),
                  const SizedBox(width: 8),
                  Text(subject.displayName),
                ],
              ),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSubject = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn môn học';
        }
        return null;
      },
    );
  }

  Widget _getSubjectIcon(Subject subject) {
    IconData iconData;
    Color color;

    switch (subject) {
      case Subject.math:
        iconData = Icons.calculate_rounded;
        color = Colors.blue;
        break;
      case Subject.physics:
        iconData = Icons.science_rounded;
        color = Colors.purple;
        break;
      case Subject.chemistry:
        iconData = Icons.biotech_rounded;
        color = Colors.green;
        break;
      case Subject.biology:
        iconData = Icons.local_florist_rounded;
        color = Colors.orange;
        break;
      case Subject.english:
        iconData = Icons.language_rounded;
        color = Colors.red;
        break;
      case Subject.literature:
        iconData = Icons.book_rounded;
        color = Colors.brown;
        break;
    }

    return Icon(iconData, color: color, size: 20);
  }
}
