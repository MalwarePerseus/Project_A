// lib/features/sleep_tracking/screens/sleep_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/data/models/sleep_data_model.dart';
import 'package:project_a/features/sleep_tracking/providers/sleep_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class SleepHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepDataAsync = ref.watch(sleepDataProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Sleep History')),
      body: sleepDataAsync.when(
        data: (sleepData) {
          if (sleepData.isEmpty) {
            return Center(child: Text('No sleep data available'));
          }

          // Sort by date, most recent first
          sleepData.sort((a, b) => b.bedtime.compareTo(a.bedtime));

          return Column(
            children: [
              _buildMonthlyCalendar(context, sleepData),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: sleepData.length,
                  itemBuilder: (context, index) {
                    return _buildSleepHistoryItem(context, sleepData[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Error loading sleep data: $error')),
      ),
    );
  }

  Widget _buildMonthlyCalendar(
    BuildContext context,
    List<SleepData> sleepData,
  ) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    // Get days in current month
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Create a map of sleep scores by day
    final Map<int, int> scoresByDay = {};
    for (final data in sleepData) {
      final day = data.bedtime.day;
      final month = data.bedtime.month;
      final year = data.bedtime.year;

      if (month == currentMonth.month && year == currentMonth.year) {
        scoresByDay[day] = data.sleepScore;
      }
    }

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(currentMonth),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(daysInMonth, (index) {
                final day = index + 1;
                final hasData = scoresByDay.containsKey(day);
                final score = scoresByDay[day] ?? 0;

                return _buildDayCell(context, day, hasData, score);
              }),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreLegend('Poor', Colors.red),
                SizedBox(width: 16),
                _buildScoreLegend('Fair', Colors.orange),
                SizedBox(width: 16),
                _buildScoreLegend('Good', Colors.lightGreen),
                SizedBox(width: 16),
                _buildScoreLegend('Excellent', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, int day, bool hasData, int score) {
    Color cellColor = Colors.transparent;

    if (hasData) {
      if (score >= 90) {
        cellColor = Colors.green.withOpacity(0.7);
      } else if (score >= 80) {
        cellColor = Colors.lightGreen.withOpacity(0.7);
      } else if (score >= 60) {
        cellColor = Colors.orange.withOpacity(0.7);
      } else {
        cellColor = Colors.red.withOpacity(0.7);
      }
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            color: hasData ? Colors.white : Colors.black,
            fontWeight: hasData ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSleepHistoryItem(BuildContext context, SleepData sleepData) {
    final hours = sleepData.sleepDuration ~/ 60;
    final minutes = sleepData.sleepDuration % 60;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(sleepData.bedtime),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSleepScoreColor(
                      sleepData.sleepScore,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Score: ${sleepData.sleepScore}',
                    style: TextStyle(
                      color: _getSleepScoreColor(sleepData.sleepScore),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.bedtime, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 4),
                Text(
                  DateFormat('h:mm a').format(sleepData.bedtime),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(' → ', style: TextStyle(color: Colors.grey.shade600)),
                Icon(Icons.wb_sunny, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 4),
                Text(
                  DateFormat('h:mm a').format(sleepData.wakeTime),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Spacer(),
                Icon(Icons.timelapse, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 4),
                Text(
                  '$hours h $minutes m',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSleepStageIndicator(
                  'Deep',
                  sleepData.sleepStages['deep'] ?? 0,
                  Colors.indigo,
                ),
                _buildSleepStageIndicator(
                  'Light',
                  sleepData.sleepStages['light'] ?? 0,
                  Colors.blue.shade300,
                ),
                _buildSleepStageIndicator(
                  'REM',
                  sleepData.sleepStages['rem'] ?? 0,
                  Colors.purple.shade300,
                ),
                _buildSleepStageIndicator(
                  'Awake',
                  sleepData.sleepStages['awake'] ?? 0,
                  Colors.orange.shade300,
                ),
              ],
            ),
            if (sleepData.snoringEpisodes.isNotEmpty) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.waves, size: 16, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text(
                    '${sleepData.snoringEpisodes.length} snoring episodes',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSleepStageIndicator(String label, int minutes, Color color) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            SizedBox(width: 4),
            Text(label),
          ],
        ),
        SizedBox(height: 4),
        Text(
          hours > 0 ? '$hours h $mins m' : '$mins m',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getSleepScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 60) return Colors.amber;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
