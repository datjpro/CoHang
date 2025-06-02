import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/classroom.dart';
import '../providers/classroom_provider.dart';
import '../providers/auth_provider.dart';

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
  late TextEditingController _scheduleController;
  late TextEditingController _groupChatLinkController;
  Subject? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(
      text: widget.classRoom?.className ?? '',
    );
    _scheduleController = TextEditingController(
      text: widget.classRoom?.schedule ?? '',
    );
    _groupChatLinkController = TextEditingController(
      text: widget.classRoom?.groupChatLink ?? '',
    );
    _selectedSubject = widget.classRoom?.subject;
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _scheduleController.dispose();
    _groupChatLinkController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate() && _selectedSubject != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final classRoomProvider = Provider.of<ClassRoomProvider>(
        context,
        listen: false,
      );

      final classRoom = ClassRoom(
        id: widget.classRoom?.id,
        className: _classNameController.text.trim(),
        subject: _selectedSubject!,
        schedule: _scheduleController.text.trim(),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              const SizedBox(height: 24),

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

              // Schedule field
              TextFormField(
                controller: _scheduleController,
                decoration: InputDecoration(
                  labelText: 'Lịch học *',
                  hintText: 'Ví dụ: Thứ 2, 4, 6 - 19:00-21:00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập lịch học';
                  }
                  return null;
                },
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
              const SizedBox(height: 24),

              // Buttons
              Row(
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
            ],
          ),
        ),
      ),
    );
  }
}
