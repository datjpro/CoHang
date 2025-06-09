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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lịch học có xung đột! Vui lòng kiểm tra lại thời gian và ngày học.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'Cập nhật lớp học thành công!'
                  : 'Thêm lớp học thành công!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (_schedule.sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất một buổi học'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    Icon(
                      widget.isEdit ? Icons.edit : Icons.add,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isEdit ? 'Sửa lớp học' : 'Thêm lớp học mới',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Class name field
                      TextFormField(
                        controller: _classNameController,
                        decoration: InputDecoration(
                          labelText: 'Tên lớp học *',
                          hintText: 'Ví dụ: Toán 10A',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên lớp học';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Subject dropdown
                      DropdownButtonFormField<Subject>(
                        value: _selectedSubject,
                        decoration: InputDecoration(
                          labelText: 'Môn học *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items:
                            Subject.values.map((subject) {
                              return DropdownMenuItem(
                                value: subject,
                                child: Text(subject.displayName),
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
                      ),
                      const SizedBox(height: 16),

                      // Schedule selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lịch học *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                      const SizedBox(height: 16),

                      // Group chat link field
                      TextFormField(
                        controller: _groupChatLinkController,
                        decoration: InputDecoration(
                          labelText: 'Link group chat',
                          hintText: 'https://...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
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
                ),
              ),

              // Footer buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(widget.isEdit ? 'Cập nhật' : 'Thêm'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
