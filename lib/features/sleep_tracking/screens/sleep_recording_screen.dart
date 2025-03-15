// lib/features/sleep_tracking/screens/sleep_recording_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/features/sleep_tracking/providers/sleep_provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class SleepRecordingScreen extends ConsumerStatefulWidget {
  @override
  _SleepRecordingScreenState createState() => _SleepRecordingScreenState();
}

class _SleepRecordingScreenState extends ConsumerState<SleepRecordingScreen> {
  bool _isRecording = false;
  DateTime? _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // Simulated noise level (in a real app, this would come from the microphone)
  double _currentNoiseLevel = 0.0;
  List<double> _noiseHistory = [];

  // Simulated snoring detection
  bool _snoringDetected = false;
  List<Map<String, dynamic>> _snoringEpisodes = [];

  @override
  void initState() {
    super.initState();
    _simulateNoise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _startTime = DateTime.now();
      _elapsed = Duration.zero;
      _noiseHistory = [];
      _snoringEpisodes = [];
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();

    // In a real app, you would process the recorded data here
    // and generate a sleep report

    final endTime = DateTime.now();
    final sleepDuration = endTime.difference(_startTime!).inMinutes;

    // Generate simulated sleep stages
    final deepSleep = (sleepDuration * 0.2).round();
    final remSleep = (sleepDuration * 0.25).round();
    final lightSleep = sleepDuration - deepSleep - remSleep - 10;
    final awake = 10; // 10 minutes awake

    // Generate a sleep score based on duration and stages
    int sleepScore = 0;

    // Duration factor (7-9 hours is ideal)
    if (sleepDuration >= 420 && sleepDuration <= 540) {
      sleepScore += 40;
    } else if (sleepDuration >= 360 || sleepDuration <= 600) {
      sleepScore += 30;
    } else {
      sleepScore += 20;
    }

    // Deep sleep factor (ideal is 20-25% of total sleep)
    final deepSleepPercent = deepSleep / sleepDuration;
    if (deepSleepPercent >= 0.2 && deepSleepPercent <= 0.25) {
      sleepScore += 30;
    } else if (deepSleepPercent >= 0.15 || deepSleepPercent <= 0.3) {
      sleepScore += 20;
    } else {
      sleepScore += 10;
    }

    // REM sleep factor (ideal is 20-25% of total sleep)
    final remSleepPercent = remSleep / sleepDuration;
    if (remSleepPercent >= 0.2 && remSleepPercent <= 0.25) {
      sleepScore += 30;
    } else if (remSleepPercent >= 0.15 || remSleepPercent <= 0.3) {
      sleepScore += 20;
    } else {
      sleepScore += 10;
    }

    // Convert simulated snoring episodes to model format
    final snoringEpisodes =
        _snoringEpisodes.map((episode) {
          return SnoringEpisode(
            startTime: DateTime.fromMillisecondsSinceEpoch(
              episode['startTime'],
            ),
            duration: episode['duration'],
            intensity: episode['intensity'],
          );
        }).toList();

    // Create sleep data
    final sleepData = SleepData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bedtime: _startTime!,
      wakeTime: endTime,
      sleepDuration: sleepDuration,
      sleepStages: {
        'deep': deepSleep,
        'light': lightSleep,
        'rem': remSleep,
        'awake': awake,
      },
      snoringEpisodes: snoringEpisodes,
      sleepScore: sleepScore,
      environmentData: {
        'temperature': 21, // simulated room temperature
        'noise': _calculateAverageNoise(),
      },
      notes: '',
    );

    // Save sleep data
    await ref.read(sleepDataProvider.notifier).addSleepData(sleepData);

    // Show results dialog
    await _showSleepResultsDialog(sleepData);

    // Navigate back
    Navigator.pop(context);
  }

  void _simulateNoise() {
    // In a real app, this would be replaced with actual microphone input
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          // Generate random noise level between 0 and 1
          _currentNoiseLevel = (DateTime.now().millisecond % 100) / 100;

          if (_isRecording) {
            _noiseHistory.add(_currentNoiseLevel);

            // Simulate snoring detection
            if (_currentNoiseLevel > 0.7 && !_snoringDetected) {
              _snoringDetected = true;
              _snoringEpisodes.add({
                'startTime': DateTime.now().millisecondsSinceEpoch,
                'duration': 0,
                'intensity': ((_currentNoiseLevel - 0.7) * 33).round(),
              });
            } else if (_currentNoiseLevel <= 0.7 && _snoringDetected) {
              _snoringDetected = false;
              if (_snoringEpisodes.isNotEmpty) {
                final lastIndex = _snoringEpisodes.length - 1;
                final startTime = _snoringEpisodes[lastIndex]['startTime'];
                final duration =
                    (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
                _snoringEpisodes[lastIndex]['duration'] = duration;
              }
            }
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  double _calculateAverageNoise() {
    if (_noiseHistory.isEmpty) return 0;
    return _noiseHistory.reduce((a, b) => a + b) / _noiseHistory.length;
  }

  Future<void> _showSleepResultsDialog(SleepData sleepData) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Sleep Results'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sleep Score: ${sleepData.sleepScore}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Duration: ${sleepData.sleepDuration ~/ 60}h ${sleepData.sleepDuration % 60}m',
                ),
                SizedBox(height: 8),
                Text(
                  'Bedtime: ${DateFormat('h:mm a').format(sleepData.bedtime)}',
                ),
                SizedBox(height: 8),
                Text(
                  'Wake time: ${DateFormat('h:mm a').format(sleepData.wakeTime)}',
                ),
                SizedBox(height: 16),
                Text(
                  'Sleep Stages:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('Deep sleep: ${sleepData.sleepStages['deep']} minutes'),
                Text('Light sleep: ${sleepData.sleepStages['light']} minutes'),
                Text('REM sleep: ${sleepData.sleepStages['rem']} minutes'),
                Text('Awake: ${sleepData.sleepStages['awake']} minutes'),
                SizedBox(height: 16),
                Text(
                  'Snoring Episodes: ${sleepData.snoringEpisodes.length}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Tracking'),
        automaticallyImplyLeading: !_isRecording,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isRecording) ...[
                        Text(
                          'Recording Sleep',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 32),
                        _buildNoiseLevel(),
                        SizedBox(height: 16),
                        if (_snoringDetected)
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Snoring Detected',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ] else ...[
                        Icon(
                          Icons.nightlight,
                          size: 80,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Ready to Track Your Sleep?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Place your phone near your bed and tap Start',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child:
                    _isRecording
                        ? ElevatedButton(
                          onPressed: _stopRecording,
                          child: Text('Stop Recording'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                        )
                        : ElevatedButton(
                          onPressed: _startRecording,
                          child: Text('Start Recording'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo.shade900,
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoiseLevel() {
    return Column(
      children: [
        Text(
          'Noise Level',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        SizedBox(height: 8),
        Container(
          width: 200,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.2),
          ),
          child: Stack(
            children: [
              Container(
                width: 200 * _currentNoiseLevel,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.green,
                      Colors.yellow,
                      Colors.orange,
                      Colors.red,
                    ],
                    stops: [0.3, 0.6, 0.8, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
