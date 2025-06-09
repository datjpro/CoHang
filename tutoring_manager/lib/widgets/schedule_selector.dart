import 'package:flutter/material.dart';
import '../models/schedule.dart';

class ScheduleSelector extends StatefulWidget {
  final ClassSchedule initialSchedule;
  final ValueChanged<ClassSchedule> onScheduleChanged;

  const ScheduleSelector({
    super.key,
    required this.initialSchedule,
    required this.onScheduleChanged,
  });

  @override
  State<ScheduleSelector> createState() => _ScheduleSelectorState();
}

class _ScheduleSelectorState extends State<ScheduleSelector> {
  late List<ScheduleSession> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = List.from(widget.initialSchedule.sessions);
  }

  void _addSession() {
    setState(() {
      _sessions.add(
        const ScheduleSession(
          dayOfWeek: DayOfWeek.monday,
          timeSlot: TimeSlot.evening19_21,
        ),
      );
    });
    _notifyChange();
  }

  void _removeSession(int index) {
    setState(() {
      _sessions.removeAt(index);
    });
    _notifyChange();
  }

  void _updateSession(int index, ScheduleSession newSession) {
    // Kiểm tra trùng lặp trước khi update
    bool hasDuplicate = false;
    for (int i = 0; i < _sessions.length; i++) {
      if (i != index &&
          _sessions[i].dayOfWeek == newSession.dayOfWeek &&
          _sessions[i].timeSlot == newSession.timeSlot) {
        hasDuplicate = true;
        break;
      }
    }

    if (hasDuplicate) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã có buổi học vào ${newSession.dayOfWeek.displayName} khung giờ ${newSession.timeSlot.displayName}!',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _sessions[index] = newSession;
    });
    _notifyChange();
  }

  void _notifyChange() {
    widget.onScheduleChanged(ClassSchedule(sessions: _sessions));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Lịch học (${_sessions.length} buổi/tuần)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addSession,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm buổi học'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Sessions list
          if (_sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có buổi học nào',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhấn "Thêm buổi học" để thêm lịch học',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sessions.length,
              separatorBuilder:
                  (context, index) =>
                      Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                return _SessionItem(
                  session: _sessions[index],
                  index: index,
                  onUpdate: (newSession) => _updateSession(index, newSession),
                  onRemove: () => _removeSession(index),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  final ScheduleSession session;
  final int index;
  final ValueChanged<ScheduleSession> onUpdate;
  final VoidCallback onRemove;

  const _SessionItem({
    required this.session,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Session number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Day selector
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thứ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DayOfWeek>(
                      value: session.dayOfWeek,
                      isExpanded: true,
                      items:
                          DayOfWeek.values
                              .map(
                                (day) => DropdownMenuItem(
                                  value: day,
                                  child: Text(day.displayName),
                                ),
                              )
                              .toList(),
                      onChanged: (newDay) {
                        if (newDay != null) {
                          onUpdate(
                            ScheduleSession(
                              dayOfWeek: newDay,
                              timeSlot: session.timeSlot,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Time slot selector
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khung giờ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TimeSlot>(
                      value: session.timeSlot,
                      isExpanded: true,
                      items:
                          TimeSlot.values
                              .map(
                                (time) => DropdownMenuItem(
                                  value: time,
                                  child: Text(time.displayName),
                                ),
                              )
                              .toList(),
                      onChanged: (newTime) {
                        if (newTime != null) {
                          onUpdate(
                            ScheduleSession(
                              dayOfWeek: session.dayOfWeek,
                              timeSlot: newTime,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            color: Colors.red.shade400,
            tooltip: 'Xóa buổi học',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
