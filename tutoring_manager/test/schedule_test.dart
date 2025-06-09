import 'package:flutter_test/flutter_test.dart';
import 'package:tutoring_manager/models/schedule.dart';

void main() {
  group('Schedule Tests', () {
    test('ClassSchedule should create empty schedule', () {
      const schedule = ClassSchedule(sessions: []);
      expect(schedule.sessions.length, 0);
      expect(schedule.toString(), 'Chưa có lịch học');
    });

    test('ClassSchedule should create schedule with sessions', () {
      const schedule = ClassSchedule(sessions: [
        ScheduleSession(
          dayOfWeek: DayOfWeek.monday,
          timeSlot: TimeSlot.evening19_21,
        ),
        ScheduleSession(
          dayOfWeek: DayOfWeek.wednesday,
          timeSlot: TimeSlot.afternoon15_17,
        ),
      ]);

      expect(schedule.sessions.length, 2);
      expect(schedule.sessionsPerWeek, 2);
    });

    test('ScheduleSession should have correct string representation', () {
      const session = ScheduleSession(
        dayOfWeek: DayOfWeek.monday,
        timeSlot: TimeSlot.evening19_21,
      );

      expect(session.toString(), 'Thứ 2 (19:00 - 21:00)');
    });

    test('ClassSchedule should serialize and deserialize correctly', () {
      const originalSchedule = ClassSchedule(sessions: [
        ScheduleSession(
          dayOfWeek: DayOfWeek.tuesday,
          timeSlot: TimeSlot.morning9_11,
        ),
      ]);

      final json = originalSchedule.toJson();
      final deserializedSchedule = ClassSchedule.fromJson(json);

      expect(deserializedSchedule.sessions.length, 1);
      expect(deserializedSchedule.sessions.first.dayOfWeek, DayOfWeek.tuesday);
      expect(deserializedSchedule.sessions.first.timeSlot, TimeSlot.morning9_11);
    });

    test('DayOfWeek should have correct display names', () {
      expect(DayOfWeek.monday.displayName, 'Thứ 2');
      expect(DayOfWeek.tuesday.displayName, 'Thứ 3');
      expect(DayOfWeek.wednesday.displayName, 'Thứ 4');
      expect(DayOfWeek.thursday.displayName, 'Thứ 5');
      expect(DayOfWeek.friday.displayName, 'Thứ 6');
      expect(DayOfWeek.saturday.displayName, 'Thứ 7');
      expect(DayOfWeek.sunday.displayName, 'Chủ nhật');
    });

    test('TimeSlot should have correct display names', () {
      expect(TimeSlot.morning7_9.displayName, '07:00 - 09:00');
      expect(TimeSlot.morning9_11.displayName, '09:00 - 11:00');
      expect(TimeSlot.afternoon13_15.displayName, '13:00 - 15:00');
      expect(TimeSlot.afternoon15_17.displayName, '15:00 - 17:00');
      expect(TimeSlot.evening17_19.displayName, '17:00 - 19:00');
      expect(TimeSlot.evening19_21.displayName, '19:00 - 21:00');
      expect(TimeSlot.evening21_23.displayName, '21:00 - 23:00');
    });

    test('ClassSchedule toDisplayString should sort sessions by day', () {
      const schedule = ClassSchedule(sessions: [
        ScheduleSession(
          dayOfWeek: DayOfWeek.friday,
          timeSlot: TimeSlot.evening19_21,
        ),
        ScheduleSession(
          dayOfWeek: DayOfWeek.monday,
          timeSlot: TimeSlot.afternoon15_17,
        ),
        ScheduleSession(
          dayOfWeek: DayOfWeek.wednesday,
          timeSlot: TimeSlot.morning9_11,
        ),
      ]);

      final displayString = schedule.toDisplayString();
      final lines = displayString.split('\n');

      expect(lines.length, 3);
      expect(lines[0], 'Thứ 2 (15:00 - 17:00)');
      expect(lines[1], 'Thứ 4 (09:00 - 11:00)');
      expect(lines[2], 'Thứ 6 (19:00 - 21:00)');
    });

    test('ClassSchedule should support copying with modifications', () {
      const originalSchedule = ClassSchedule(sessions: [
        ScheduleSession(
          dayOfWeek: DayOfWeek.monday,
          timeSlot: TimeSlot.evening19_21,
        ),
      ]);

      final newSchedule = originalSchedule.copyWith(sessions: [
        const ScheduleSession(
          dayOfWeek: DayOfWeek.tuesday,
          timeSlot: TimeSlot.morning9_11,
        ),
        const ScheduleSession(
          dayOfWeek: DayOfWeek.thursday,
          timeSlot: TimeSlot.afternoon15_17,
        ),
      ]);

      expect(originalSchedule.sessions.length, 1);
      expect(newSchedule.sessions.length, 2);
      expect(newSchedule.sessions.first.dayOfWeek, DayOfWeek.tuesday);
    });
  });
}
