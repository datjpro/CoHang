import 'schedule.dart';

enum Subject {
  math('Toán'),
  physics('Lý'),
  chemistry('Hóa'),
  biology('Sinh'),
  english('Tiếng Anh'),
  literature('Văn');

  const Subject(this.displayName);
  final String displayName;
}

class ClassRoom {
  final int? id;
  final String className;
  final Subject subject;
  final ClassSchedule schedule; // Lịch học với các buổi học cụ thể
  final String groupChatLink;
  final int teacherId;
  final DateTime createdAt;
  ClassRoom({
    this.id,
    required this.className,
    required this.subject,
    required this.schedule,
    required this.groupChatLink,
    required this.teacherId,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'className': className,
      'subject': subject.name,
      'schedule': schedule.toJson(),
      'groupChatLink': groupChatLink,
      'teacherId': teacherId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ClassRoom.fromMap(Map<String, dynamic> map) {
    return ClassRoom(
      id: map['id'],
      className: map['className'],
      subject: Subject.values.firstWhere((s) => s.name == map['subject']),
      schedule: ClassSchedule.fromJson(map['schedule'] ?? ''),
      groupChatLink: map['groupChatLink'],
      teacherId: map['teacherId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
  ClassRoom copyWith({
    int? id,
    String? className,
    Subject? subject,
    ClassSchedule? schedule,
    String? groupChatLink,
    int? teacherId,
    DateTime? createdAt,
  }) {
    return ClassRoom(
      id: id ?? this.id,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      schedule: schedule ?? this.schedule,
      groupChatLink: groupChatLink ?? this.groupChatLink,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
