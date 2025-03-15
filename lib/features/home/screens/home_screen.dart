// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/features/alarm/providers/alarm_provider.dart';
import 'package:project_a/features/alarm/screens/create_alarm_screen.dart';
import 'package:project_a/features/sleep_tracking/screens/sleep_dashboard_screen.dart';
import 'package:project_a/features/sounds/screens/sound_library_screen.dart';
import 'package:project_a/features/settings/screens/settings_screen.dart';
import 'package:project_a/data/models/alarm_model.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AlarmListTab(),
    SleepDashboardScreen(),
    SoundLibraryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Alarms'),
          BottomNavigationBarItem(icon: Icon(Icons.nightlight), label: 'Sleep'),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Sounds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class AlarmListTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Super Alarmy'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // Navigate to alarm history
            },
          ),
        ],
      ),
      body: alarmsAsync.when(
        data: (alarms) {
          if (alarms.isEmpty) {
            return _buildEmptyState(context);
          }

          // Find the next alarm
          final now = DateTime.now();
          final nextAlarm =
              alarms.where((alarm) => alarm.isEnabled).map((alarm) {
                  final alarmTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    alarm.hour,
                    alarm.minute,
                  );

                  // If alarm time is in the past, add a day
                  final adjustedTime =
                      alarmTime.isBefore(now)
                          ? alarmTime.add(Duration(days: 1))
                          : alarmTime;

                  return MapEntry(alarm, adjustedTime);
                }).toList()
                ..sort((a, b) => a.value.compareTo(b.value));

          return Column(
            children: [
              if (nextAlarm.isNotEmpty) _buildNextAlarmCard(nextAlarm.first),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: alarms.length,
                  itemBuilder: (context, index) {
                    return _buildAlarmItem(context, ref, alarms[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Error loading alarms: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAlarmScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty_alarm.png', height: 200),
          SizedBox(height: 24),
          Text(
            'No Alarms Yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          Text(
            'Tap the + button to create your first alarm',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextAlarmCard(MapEntry<AlarmModel, DateTime> nextAlarm) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Alarm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _getTimeUntilAlarm(nextAlarm.value),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.alarm, size: 48, color: Colors.orange),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextAlarm.key.formattedTime,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      nextAlarm.key.label.isNotEmpty
                          ? nextAlarm.key.label
                          : nextAlarm.key.repeatDaysText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (nextAlarm.key.missionType != 'none') ...[
              SizedBox(height: 8),
              Chip(
                label: Text(_getMissionTypeText(nextAlarm.key.missionType)),
                avatar: Icon(
                  _getMissionTypeIcon(nextAlarm.key.missionType),
                  size: 16,
                ),
                backgroundColor: Colors.blue.shade50,
                padding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmItem(
    BuildContext context,
    WidgetRef ref,
    AlarmModel alarm,
  ) {
    return Dismissible(
      key: Key('alarm-${alarm.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Delete Alarm'),
                content: Text('Are you sure you want to delete this alarm?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        ref.read(alarmsProvider.notifier).deleteAlarm(alarm.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alarm deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(alarmsProvider.notifier).addAlarm(alarm);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateAlarmScreen(alarm: alarm),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alarm.formattedTime,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              alarm.isEnabled
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        alarm.label.isNotEmpty
                            ? alarm.label
                            : alarm.repeatDaysText,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      if (alarm.missionType != 'none') ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _getMissionTypeIcon(alarm.missionType),
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 4),
                            Text(
                              _getMissionTypeText(alarm.missionType),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: alarm.isEnabled,
                  onChanged: (value) {
                    ref.read(alarmsProvider.notifier).toggleAlarm(alarm.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeUntilAlarm(DateTime alarmTime) {
    final now = DateTime.now();
    final difference = alarmTime.difference(now);

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return 'in ${hours}h ${minutes}m';
    } else {
      return 'in ${minutes}m';
    }
  }

  String _getMissionTypeText(String missionType) {
    switch (missionType) {
      case 'math':
        return 'Math Problem';
      case 'photo':
        return 'Photo Mission';
      case 'shake':
        return 'Shake Mission';
      case 'memory':
        return 'Memory Game';
      case 'barcode':
        return 'Scan Barcode';
      case 'steps':
        return 'Step Counter';
      default:
        return 'No Mission';
    }
  }

  IconData _getMissionTypeIcon(String missionType) {
    switch (missionType) {
      case 'math':
        return Icons.calculate;
      case 'photo':
        return Icons.camera_alt;
      case 'shake':
        return Icons.vibration;
      case 'memory':
        return Icons.grid_view;
      case 'barcode':
        return Icons.qr_code;
      case 'steps':
        return Icons.directions_walk;
      default:
        return Icons.alarm;
    }
  }
}
