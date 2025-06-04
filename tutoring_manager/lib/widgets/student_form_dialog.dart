import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../providers/classroom_provider.dart';

class StudentFormDialog extends StatefulWidget {
  final int classRoomId;
  final Student? student;

  const StudentFormDialog({super.key, required this.classRoomId, this.student});

  bool get isEdit => student != null;

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _schoolClassController;
  late TextEditingController _phoneController;
  late TextEditingController _guardianNameController;
  late TextEditingController _guardianPhoneController;
  late TextEditingController _emailController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _currentAddressController;
  late TextEditingController _noteController;

  String _selectedGender = 'Nam';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.student?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.student?.lastName ?? '',
    );
    _schoolClassController = TextEditingController(
      text: widget.student?.schoolClass ?? '',
    );
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _guardianNameController = TextEditingController(
      text: widget.student?.guardianName ?? '',
    );
    _guardianPhoneController = TextEditingController(
      text: widget.student?.guardianPhone ?? '',
    );
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _birthPlaceController = TextEditingController(
      text: widget.student?.birthPlace ?? '',
    );
    _currentAddressController = TextEditingController(
      text: widget.student?.currentAddress ?? '',
    );
    _noteController = TextEditingController(text: widget.student?.note ?? '');
    if (widget.student != null) {
      _selectedGender = widget.student!.gender;
      _selectedDate = widget.student!.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _schoolClassController.dispose();
    _phoneController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _emailController.dispose();
    _birthPlaceController.dispose();
    _currentAddressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final classRoomProvider = Provider.of<ClassRoomProvider>(
        context,
        listen: false,
      );
      final student = Student(
        id: widget.student?.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDate,
        birthPlace: _birthPlaceController.text.trim(),
        currentAddress: _currentAddressController.text.trim(),
        schoolClass: _schoolClassController.text.trim(),
        phone:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        guardianName: _guardianNameController.text.trim(),
        guardianPhone: _guardianPhoneController.text.trim(),
        email: _emailController.text.trim(),
        ethnicity: 'Kinh',
        note: _noteController.text.trim(),
        classRoomId: widget.classRoomId,
        createdAt: widget.student?.createdAt ?? DateTime.now(),
      );
      if (widget.isEdit) {
        await classRoomProvider.updateStudent(student);
      } else {
        await classRoomProvider.addStudent(student);
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'Cập nhật học sinh thành công!'
                  : 'Thêm học sinh thành công!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    // Basic Vietnamese phone number validation
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.isEdit ? Icons.edit : Icons.person_add,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isEdit
                          ? 'Sửa thông tin học sinh'
                          : 'Thêm học sinh mới',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Name fields row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên đệm *',
                          hintText: 'Nguyễn Văn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập họ và tên đệm';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'Tên *',
                          hintText: 'A',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gender and Date of Birth row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Giới tính *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items:
                            ['Nam', 'Nữ', 'Khác'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Ngày sinh *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_selectedDate.day.toString().padLeft(2, '0')}/'
                            '${_selectedDate.month.toString().padLeft(2, '0')}/'
                            '${_selectedDate.year}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Birth place and School class row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _birthPlaceController,
                        decoration: InputDecoration(
                          labelText: 'Nơi sinh',
                          hintText: 'Hà Nội',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _schoolClassController,
                        decoration: InputDecoration(
                          labelText: 'Lớp học ở trường *',
                          hintText: '10A1',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập lớp học';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Current address
                TextFormField(
                  controller: _currentAddressController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ hiện tại',
                    hintText:
                        'Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Guardian info and contact row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _guardianNameController,
                        decoration: InputDecoration(
                          labelText: 'Tên người thân *',
                          hintText: 'Nguyễn Văn B',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên người thân';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại học sinh',
                          hintText: '0123456789',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: _validatePhone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Guardian phone and Email row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _guardianPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại người thân *',
                          hintText: '0123456789',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: _validatePhone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'email@example.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Email không hợp lệ';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Note field
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
                    hintText: 'Thông tin bổ sung về học sinh...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Các trường có dấu * là bắt buộc',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        backgroundColor: Colors.green.shade600,
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
      ),
    );
  }
}
