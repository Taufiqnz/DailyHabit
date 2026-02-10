import 'package:hive/hive.dart';
import '../models/habit.dart';

class HabitService {
  static const String boxName = 'habitsBox';

  Future<Box> openBox() async {
    return await Hive.openBox(boxName);
  }

  Future<void> addHabit(Habit habit) async {
    final box = await openBox();
    box.put(habit.id, habit);
  }

  List<Habit> getHabits(Box box) {
    return box.values.cast<Habit>().toList();
  }
}
