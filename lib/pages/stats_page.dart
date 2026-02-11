import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_provider.dart';
import '../utils/date_helper.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);
    final last7 = last7Days().reversed.toList();

    // 🔥 HITUNG DATA SUMMARY
    int totalWeek = 0;
    int bestDay = 0;

    for (var date in last7) {
      int count = provider.habits
          .where((habit) => habit.completedDates.contains(date))
          .length;

      totalWeek += count;

      if (count > bestDay) {
        bestDay = count;
      }
    }

    double average = last7.isEmpty ? 0 : totalWeek / last7.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Stats")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 SUMMARY CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🔥 Total minggu ini: $totalWeek",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text("📈 Hari terbaik: $bestDay habit"),
                    const SizedBox(height: 8),
                    Text("📊 Rata-rata: ${average.toStringAsFixed(1)} / hari"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔥 LINE CHART
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: provider.habits.isEmpty
                      ? 5
                      : provider.habits.length.toDouble(),

                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= last7.length) {
                            return const SizedBox();
                          }

                          final date = last7[index].substring(8);

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              date,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                      ),
                      spots: List.generate(last7.length, (index) {
                        final date = last7[index];

                        int completedCount = provider.habits
                            .where(
                              (habit) => habit.completedDates.contains(date),
                            )
                            .length;

                        return FlSpot(
                          index.toDouble(),
                          completedCount.toDouble(),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
