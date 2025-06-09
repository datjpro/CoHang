enum DayOfWeek {
  monday('Thứ 2'),
  tuesday('Thứ 3'),
  wednesday('Thứ 4'),
  thursday('Thứ 5'),
  friday('Thứ 6'),
  saturday('Thứ 7'),
  sunday('Chủ nhật');

  const DayOfWeek(this.displayName);
  final String displayName;
}

enum TimeSlot {
  morning7_9('07:00 - 09:00'),
  morning9_11('09:00 - 11:00'),
  afternoon13_15('13:00 - 15:00'),
  afternoon15_17('15:00 - 17:00'),
  evening17_19('17:00 - 19:00'),
  evening19_21('19:00 - 21:00'),
  evening21_23('21:00 - 23:00');

  const TimeSlot(this.displayName);
  final String displayName;
}

class ScheduleSession {
  final DayOfWeek dayOfWeek;
  final TimeSlot timeSlot;

  const ScheduleSession({required this.dayOfWeek, required this.timeSlot});

  Map<String, dynamic> toMap() {
    return {'dayOfWeek': dayOfWeek.name, 'timeSlot': timeSlot.name};
  }

  factory ScheduleSession.fromMap(Map<String, dynamic> map) {
    return ScheduleSession(
      dayOfWeek: DayOfWeek.values.firstWhere((d) => d.name == map['dayOfWeek']),
      timeSlot: TimeSlot.values.firstWhere((t) => t.name == map['timeSlot']),
    );
  }

  @override
  String toString() {
    return '${dayOfWeek.displayName} (${timeSlot.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleSession &&
        other.dayOfWeek == dayOfWeek &&
        other.timeSlot == timeSlot;
  }

  @override
  int get hashCode => dayOfWeek.hashCode ^ timeSlot.hashCode;
}

class ClassSchedule {
  final List<ScheduleSession> sessions;

  const ClassSchedule({required this.sessions});

  Map<String, dynamic> toMap() {
    return {'sessions': sessions.map((s) => s.toMap()).toList()};
  }

  factory ClassSchedule.fromMap(Map<String, dynamic> map) {
    return ClassSchedule(
      sessions:
          (map['sessions'] as List<dynamic>)
              .map((s) => ScheduleSession.fromMap(s as Map<String, dynamic>))
              .toList(),
    );
  }

  factory ClassSchedule.fromJson(String jsonString) {
    if (jsonString.isEmpty) return const ClassSchedule(sessions: []);

    try {
      final Map<String, dynamic> map = {};
      // Parse simple format: "sessions:[{dayOfWeek:monday,timeSlot:evening19_21}]"
      if (jsonString.contains('sessions:')) {
        final sessionsStr = jsonString.split('sessions:')[1];
        // Simple parsing for now, can be improved
        return const ClassSchedule(sessions: []);
      }
      return ClassSchedule.fromMap(map);
    } catch (e) {
      return const ClassSchedule(sessions: []);
    }
  }

  String toJson() {
    if (sessions.isEmpty) return '';
    return 'sessions:[${sessions.map((s) => '{dayOfWeek:${s.dayOfWeek.name},timeSlot:${s.timeSlot.name}}').join(',')}]';
  }

  @override
  String toString() {
    if (sessions.isEmpty) return 'Chưa có lịch học';
    return sessions.map((s) => s.toString()).join(', ');
  }

  ClassSchedule copyWith({List<ScheduleSession>? sessions}) {
    return ClassSchedule(sessions: sessions ?? this.sessions);
  }
}
