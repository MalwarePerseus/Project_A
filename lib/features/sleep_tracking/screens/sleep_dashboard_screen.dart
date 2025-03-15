// lib/features/sleep_tracking/screens/sleep_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/data/models/sleep_data_model.dart';
import 'package:project_a/features/sleep_tracking/providers/sleep_provider.dart';
import 'package:project_a/features/sleep_tracking/screens/sleep_recording_screen.dart';
import 'package:project_a/features/sleep_tracking/screens/sleep_history_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SleepDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepDataAsync = ref.watch(sleepDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Insights'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SleepHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: sleepDataAsync.when(
        data: (sleepData) {
          if (sleepData.isEmpty) {
            return _buildEmptySleepData(context);
          }

          // Sort by date, most recent first
          sleepData.sort((a, b) => b.bedtime.compareTo(a.bedtime));

          // Get the most recent sleep data
          final latestSleep = sleepData.first;

          // Get the last week of sleep data for the chart
          final lastWeekData =
              sleepData
                  .where(
                    (data) => data.bedtime.isAfter(
                      DateTime.now().subtract(Duration(days: 7)),
                    ),
                  )
                  .toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSleepScoreCard(context, latestSleep),
                SizedBox(height: 16),
                _buildSleepDurationCard(context, latestSleep),
                SizedBox(height: 16),
                _buildSleepStagesCard(context, latestSleep),
                SizedBox(height: 16),
                _buildWeeklyTrendCard(context, lastWeekData),
                SizedBox(height: 16),
                if (latestSleep.snoringEpisodes.isNotEmpty)
                  _buildSnoringCard(context, latestSleep),
                SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Error loading sleep data: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SleepRecordingScreen()),
          );
        },
        icon: Icon(Icons.nightlight),
        label: Text('Track Sleep'),
      ),
    );
  }

  Widget _buildEmptySleepData(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty_sleep.png', height: 200),
          SizedBox(height: 24),
          Text(
            'No Sleep Data Yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          Text(
            'Track your sleep to see insights and improve your rest',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SleepRecordingScreen()),
              );
            },
            icon: Icon(Icons.nightlight),
            label: Text('Start Tracking'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepScoreCard(BuildContext context, SleepData sleepData) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Night\'s Sleep',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildSleepScoreCircle(context, sleepData.sleepScore),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSleepScoreText(sleepData.sleepScore),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getSleepScoreColor(sleepData.sleepScore),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM d').format(sleepData.bedtime),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepScoreCircle(BuildContext context, int score) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            _getSleepScoreColor(score).withOpacity(0.7),
            _getSleepScoreColor(score),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getSleepScoreColor(score).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          score.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSleepDurationCard(BuildContext context, SleepData sleepData) {
    final hours = sleepData.sleepDuration ~/ 60;
    final minutes = sleepData.sleepDuration % 60;

    final bedtimeFormatted = DateFormat('h:mm a').format(sleepData.bedtime);
    final wakeTimeFormatted = DateFormat('h:mm a').format(sleepData.wakeTime);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Duration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Bedtime',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      bedtimeFormatted,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Wake Time',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      wakeTimeFormatted,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Duration',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$hours h $minutes m',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepStagesCard(BuildContext context, SleepData sleepData) {
    final deepSleep = sleepData.sleepStages['deep'] ?? 0;
    final lightSleep = sleepData.sleepStages['light'] ?? 0;
    final remSleep = sleepData.sleepStages['rem'] ?? 0;
    final awake = sleepData.sleepStages['awake'] ?? 0;

    final totalMinutes = deepSleep + lightSleep + remSleep + awake;

    final deepPercent = totalMinutes > 0 ? deepSleep / totalMinutes : 0;
    final lightPercent = totalMinutes > 0 ? lightSleep / totalMinutes : 0;
    final remPercent = totalMinutes > 0 ? remSleep / totalMinutes : 0;
    final awakePercent = totalMinutes > 0 ? awake / totalMinutes : 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Stages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: (deepPercent * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: (lightPercent * 100).toInt(),
                    child: Container(color: Colors.blue.shade300),
                  ),
                  Expanded(
                    flex: (remPercent * 100).toInt(),
                    child: Container(color: Colors.purple.shade300),
                  ),
                  Expanded(
                    flex: (awakePercent * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        color: Colors.orange.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSleepStageIndicator('Deep', deepSleep, Colors.indigo),
                _buildSleepStageIndicator(
                  'Light',
                  lightSleep,
                  Colors.blue.shade300,
                ),
                _buildSleepStageIndicator(
                  'REM',
                  remSleep,
                  Colors.purple.shade300,
                ),
                _buildSleepStageIndicator(
                  'Awake',
                  awake,
                  Colors.orange.shade300,
                ),
              ],
            ),
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

  Widget _buildWeeklyTrendCard(BuildContext context, List<SleepData> weekData) {
    // Sort by date, oldest first for the chart
    weekData.sort((a, b) => a.bedtime.compareTo(b.bedtime));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child:
                  weekData.isEmpty
                      ? Center(child: Text('Not enough data to show trends'))
                      : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
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
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < weekData.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        DateFormat('E').format(
                                          weekData[value.toInt()].bedtime,
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: weekData.length - 1.0,
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                weekData.length,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  weekData[index].sleepScore.toDouble(),
                                ),
                              ),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.2),
                              ),
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

  Widget _buildSnoringCard(BuildContext context, SleepData sleepData) {
    final totalSnoringDuration = sleepData.snoringEpisodes.fold(
      0,
      (sum, episode) => sum + episode.duration,
    );

    final minutes = totalSnoringDuration ~/ 60;
    final seconds = totalSnoringDuration % 60;

    final maxIntensity = sleepData.snoringEpisodes.fold(
      0,
      (max, episode) => episode.intensity > max ? episode.intensity : max,
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Snoring',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Episodes',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      sleepData.snoringEpisodes.length.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Duration',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$minutes m $seconds s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Intensity',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.waves,
                          size: 16,
                          color:
                              index < maxIntensity / 2
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSleepScoreText(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 60) return 'Fair';
    if (score >= 40) return 'Poor';
    return 'Very Poor';
  }

  Color _getSleepScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 60) return Colors.amber;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
