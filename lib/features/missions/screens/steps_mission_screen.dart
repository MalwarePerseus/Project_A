// lib/features/missions/screens/steps_mission_screen.dart
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class StepsMissionScreen extends StatefulWidget {
  final Map<String, dynamic> missionSettings;
  final VoidCallback onMissionComplete;

  const StepsMissionScreen({
    Key? key,
    required this.missionSettings,
    required this.onMissionComplete,
  }) : super(key: key);

  @override
  _StepsMissionScreenState createState() => _StepsMissionScreenState();
}

class _StepsMissionScreenState extends State<StepsMissionScreen>
    with SingleTickerProviderStateMixin {
  late int _targetSteps;
  late double _sensitivity;
  int _stepCount = 0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Step detection variables
  double _lastMagnitude = 0;
  bool _isStepUp = false;
  DateTime _lastStepTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    _targetSteps = widget.missionSettings['count'] ?? 20;

    // Set sensitivity threshold based on setting
    final sensitivitySetting =
        widget.missionSettings['sensitivity'] ?? 'medium';
    switch (sensitivitySetting) {
      case 'low':
        _sensitivity = 1.2;
        break;
      case 'medium':
        _sensitivity = 1.5;
        break;
      case 'high':
        _sensitivity = 1.8;
        break;
      default:
        _sensitivity = 1.5;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startListening();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startListening() {
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      // Calculate magnitude of acceleration
      final double magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Simple step detection algorithm
      final now = DateTime.now();
      final timeDiff = now.difference(_lastStepTime).inMilliseconds;

      // Ensure minimum time between steps (avoid counting bounces)
      if (timeDiff > 300) {
        if (!_isStepUp &&
            magnitude > _lastMagnitude &&
            magnitude > _sensitivity * 9.8) {
          _isStepUp = true;
        } else if (_isStepUp &&
            magnitude < _lastMagnitude &&
            magnitude < _sensitivity * 9.8) {
          _isStepUp = false;
          _lastStepTime = now;

          // Count a step
          setState(() {
            _stepCount++;

            // Animate step
            _animationController.forward(from: 0.0);

            // Check if mission complete
            if (_stepCount >= _targetSteps) {
              widget.onMissionComplete();
            }
          });
        }
      }

      _lastMagnitude = magnitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _stepCount / _targetSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text('Step Counter Mission'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Walk to turn off the alarm',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              // Step animation
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.directions_walk,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              SizedBox(height: 48),
              // Progress indicator
              Text(
                '$_stepCount / $_targetSteps',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 20,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: 48),
              Text(
                'Keep walking!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
