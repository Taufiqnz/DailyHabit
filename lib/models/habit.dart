import 'package:habit_tracker/utils/date_helper.dart';

class Habit {
  final String id;
  final String name;
  final List<String> completedDates;

  Habit({required this.id, required this.name, required this.completedDates});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'completedDates': completedDates};
  }

  factory Habit.fromMap(Map map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      completedDates: List<String>.from(map['completedDates']),
    );
  }

  int getStreak() {
    int streak = 0;
    DateTime day = DateTime.now();

    while (completedDates.contains("${day.year}-${day.month}-${day.day}")) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int weeklyProgress() {
    final days = last7Days();
    return days.where((d) => completedDates.contains(d)).length;
  }
}
