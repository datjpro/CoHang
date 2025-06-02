class Student {
  final int? id;
  final String firstName;
  final String lastName;
  final String schoolClass; // Lớp học ở trường (ví dụ: "10A1")
  final String phone;
  final String parentName;
  final String parentPhone;
  final int classRoomId;
  final List<Attendance> attendances;
  final DateTime createdAt;

  Student({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.schoolClass,
    required this.phone,
    required this.parentName,
    required this.parentPhone,
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
      'schoolClass': schoolClass,
      'phone': phone,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'classRoomId': classRoomId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      schoolClass: map['schoolClass'],
      phone: map['phone'],
      parentName: map['parentName'],
      parentPhone: map['parentPhone'],
      classRoomId: map['classRoomId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Student copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? schoolClass,
    String? phone,
    String? parentName,
    String? parentPhone,
    int? classRoomId,
    List<Attendance>? attendances,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      schoolClass: schoolClass ?? this.schoolClass,
      phone: phone ?? this.phone,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
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
