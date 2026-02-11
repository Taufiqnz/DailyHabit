import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_habit_page.dart';
import '../providers/habit_provider.dart';
import '../utils/date_helper.dart';
import 'stats_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 AMBIL SEKALI DI SINI
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DailyHabit',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsPage()),
              );
            },
          ),
        ],
      ),

      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Consumer<HabitProvider>(
          builder: (context, provider, _) {
            if (provider.habits.isEmpty) {
              return buildEmptyState(context);
            }

            return ListView.builder(
              itemCount: provider.habits.length,
              itemBuilder: (context, index) {
                final habit = provider.habits[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      habit.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "🔥 ${habit.getStreak()} hari  |  📊 ${habit.weeklyProgress()}/7 minggu ini",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    trailing: habit.completedDates.contains(todayDate())
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 28,
                          )
                        : const Icon(Icons.circle_outlined, size: 28),

                    // ✅ TOGGLE HABIT
                    onTap: () {
                      habitProvider.toggleHabit(habit.id);
                    },

                    // 🗑️ DELETE + UNDO
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) {
                          return SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Edit'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showEditDialog(context, habit);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);

                                    final provider = Provider.of<HabitProvider>(
                                      context,
                                      listen: false,
                                    );

                                    provider.deleteHabit(habit.id);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Habit dihapus'),
                                        action: SnackBarAction(
                                          label: 'UNDO',
                                          onPressed: () {
                                            provider.undoDelete();
                                          },
                                        ),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _showEditDialog(BuildContext context, habit) {
  final controller = TextEditingController(text: habit.name);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Edit Habit"),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: "Nama Habit"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              Provider.of<HabitProvider>(
                context,
                listen: false,
              ).editHabit(habit.id, controller.text.trim());
            }
            Navigator.pop(context);
          },
          child: const Text("Simpan"),
        ),
      ],
    ),
  );
}

Widget buildEmptyState(BuildContext context) {
  final outlineColor = Theme.of(context).colorScheme.outline;

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rounded, size: 96, color: outlineColor),
          const SizedBox(height: 16),
          const Text(
            'Belum ada habit',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai kebiasaan baik pertamamu.\nTekan tombol + di bawah.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: outlineColor),
          ),
        ],
      ),
    ),
  );
}
