// lib/features/missions/screens/shake_mission_screen.dart
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class ShakeMissionScreen extends StatefulWidget {
  final Map<String, dynamic> missionSettings;
  final VoidCallback onMissionComplete;

  const ShakeMissionScreen({
    Key? key,
    required this.missionSettings,
    required this.onMissionComplete,
  }) : super(key: key);

  @override
  _ShakeMissionScreenState createState() => _ShakeMissionScreenState();
}

class _ShakeMissionScreenState extends State<ShakeMissionScreen>
    with SingleTickerProviderStateMixin {
  late int _targetShakes;
  late double _sensitivity;
  int _shakeCount = 0;
  bool _isShaking = false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _targetShakes = widget.missionSettings['count'] ?? 30;

    // Set sensitivity threshold based on setting
    final sensitivitySetting =
        widget.missionSettings['sensitivity'] ?? 'medium';
    switch (sensitivitySetting) {
      case 'low':
        _sensitivity = 20.0;
        break;
      case 'medium':
        _sensitivity = 15.0;
        break;
      case 'high':
        _sensitivity = 10.0;
        break;
      default:
        _sensitivity = 15.0;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
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
      final double acceleration =
          event.x * event.x + event.y * event.y + event.z * event.z;

      // Check if acceleration exceeds threshold
      if (acceleration > _sensitivity * _sensitivity) {
        if (!_isShaking) {
          setState(() {
            _isShaking = true;
            _shakeCount++;

            // Animate shake
            _animationController.forward(from: 0.0);

            // Check if mission complete
            if (_shakeCount >= _targetShakes) {
              widget.onMissionComplete();
            }
          });

          // Reset shake state after a short delay
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isShaking = false;
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _shakeCount / _targetShakes;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shake Mission'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Shake your phone to turn off the alarm',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              // Shake animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin(_animationController.value * 10) * 10,
                      0,
                    ),
                    child: child,
                  );
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.vibration,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: 48),
              // Progress indicator
              Text(
                '$_shakeCount / $_targetShakes',
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
                'Keep shaking!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
