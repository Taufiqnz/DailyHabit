import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/habit.dart';
import '../utils/date_helper.dart';

class HabitProvider extends ChangeNotifier {
  static const String boxName = 'habitsBox';

  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  Habit? _lastDeletedHabit;
  int? _lastDeletedIndex;

  HabitProvider() {
    loadHabits();
  }

  Future<void> loadHabits() async {
    final box = await Hive.openBox(boxName);
    final data = box.get('habits', defaultValue: []);

    _habits = (data as List)
        .map((e) => Habit.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    notifyListeners();
  }

  Future<void> saveHabits() async {
    final box = await Hive.openBox(boxName);
    final data = _habits.map((h) => h.toMap()).toList();
    await box.put('habits', data);
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    saveHabits();
    notifyListeners();
  }

  void toggleHabit(String habitId) {
    final today = todayDate();
    final habit = _habits.firstWhere((h) => h.id == habitId);

    if (habit.completedDates.contains(today)) {
      habit.completedDates.remove(today);
    } else {
      habit.completedDates.add(today);
    }

    saveHabits();
    notifyListeners();
  }

  void deleteHabit(String habitId) {
    _lastDeletedIndex = _habits.indexWhere((h) => h.id == habitId);

    _lastDeletedHabit = _habits.firstWhere((h) => h.id == habitId);

    _habits.removeAt(_lastDeletedIndex!);
    saveHabits();
    notifyListeners();
  }

  void undoDelete() {
    if (_lastDeletedHabit != null && _lastDeletedIndex != null) {
      _habits.insert(_lastDeletedIndex!, _lastDeletedHabit!);

      _lastDeletedHabit = null;
      _lastDeletedIndex = null;

      saveHabits();
      notifyListeners();
    }
  }
}
