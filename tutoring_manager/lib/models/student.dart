class Student {
  final int? id;
  final String firstName;
  final String lastName;
  final String gender; // Giới tính
  final DateTime dateOfBirth; // Ngày sinh
  final String birthPlace; // Nơi sinh
  final String currentAddress; // Địa chỉ hiện tại
  final String schoolClass; // Lớp học ở trường (ví dụ: "10A1")
  final String? phone; // Số điện thoại học sinh (không bắt buộc)
  final String guardianName; // Người thân
  final String guardianPhone; // SĐT người thân
  final String email; // Email
  final String ethnicity; // Dân tộc
  final String? note; // Ghi chú
  final int classRoomId;
  final List<Attendance> attendances;
  final DateTime createdAt;
  Student({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.birthPlace,
    required this.currentAddress,
    required this.schoolClass,
    this.phone,
    required this.guardianName,
    required this.guardianPhone,
    required this.email,
    required this.ethnicity,
    this.note,
    required this.classRoomId,
    this.attendances = const [],
    required this.createdAt,
  });

  String get fullName => '$lastName $firstName';
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'birthPlace': birthPlace,
      'currentAddress': currentAddress,
      'schoolClass': schoolClass,
      'phone': phone,
      'guardianName': guardianName,
      'guardianPhone': guardianPhone,
      'email': email,
      'ethnicity': ethnicity,
      'note': note,
      'classRoomId': classRoomId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      gender: map['gender'] ?? 'Khác',
      dateOfBirth:
          map['dateOfBirth'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'])
              : DateTime.now(),
      birthPlace: map['birthPlace'] ?? '',
      currentAddress: map['currentAddress'] ?? '',
      schoolClass: map['schoolClass'],
      phone: map['phone'],
      guardianName: map['guardianName'] ?? '',
      guardianPhone: map['guardianPhone'] ?? '',
      email: map['email'] ?? '',
      ethnicity: map['ethnicity'] ?? 'Kinh',
      note: map['note'],
      classRoomId: map['classRoomId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
  Student copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    String? birthPlace,
    String? currentAddress,
    String? schoolClass,
    String? phone,
    String? guardianName,
    String? guardianPhone,
    String? email,
    String? ethnicity,
    String? note,
    int? classRoomId,
    List<Attendance>? attendances,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      birthPlace: birthPlace ?? this.birthPlace,
      currentAddress: currentAddress ?? this.currentAddress,
      schoolClass: schoolClass ?? this.schoolClass,
      phone: phone ?? this.phone,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      email: email ?? this.email,
      ethnicity: ethnicity ?? this.ethnicity,
      note: note ?? this.note,
      classRoomId: classRoomId ?? this.classRoomId,
      attendances: attendances ?? this.attendances,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Attendance {
  final int? id;
  final int studentId;
  final DateTime date;
  final bool isPresent;
  final String? note;

  Attendance({
    this.id,
    required this.studentId,
    required this.date,
    required this.isPresent,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.millisecondsSinceEpoch,
      'isPresent': isPresent ? 1 : 0,
      'note': note,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      studentId: map['studentId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isPresent: map['isPresent'] == 1,
      note: map['note'],
    );
  }

  Attendance copyWith({
    int? id,
    int? studentId,
    DateTime? date,
    bool? isPresent,
    String? note,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      isPresent: isPresent ?? this.isPresent,
      note: note ?? this.note,
    );
  }
}
