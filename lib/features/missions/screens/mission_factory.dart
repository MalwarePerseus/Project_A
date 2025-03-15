// lib/features/missions/screens/mission_factory.dart
import 'package:flutter/material.dart';
import 'package:project_a/features/missions/screens/math_mission_screen.dart';
import 'package:project_a/features/missions/screens/shake_mission_screen.dart';
import 'package:project_a/features/missions/screens/photo_mission_screen.dart';
import 'package:project_a/features/missions/screens/memory_mission_screen.dart';
import 'package:project_a/features/missions/screens/barcode_mission_screen.dart';
import 'package:project_a/features/missions/screens/steps_mission_screen.dart';

class MissionFactory {
  static Widget createMissionScreen({
    required String missionType,
    required Map<String, dynamic> missionSettings,
    required VoidCallback onMissionComplete,
  }) {
    switch (missionType) {
      case 'math':
        return MathMissionScreen(
          missionSettings: missionSettings,
          onMissionComplete: onMissionComplete,
        );
      case 'shake':
        return ShakeMissionScreen(
          missionSettings: missionSettings,
          onMissionComplete: onMissionComplete,
        );
      case 'photo':
        return PhotoMissionScreen(
          missionSettings: missionSettings,
          onMissionComplete: onMissionComplete,
        );
      case 'memory':
        return MemoryMissionScreen(
          missionSettings: missionSettings,
          onMissionComplete: onMissionComplete,
        );
      case 'barcode':
        return BarcodeMissionScreen(
          missionSettings: missionSettings,
          onMissionComplete: onMissionComplete,
        );
      case 'steps':
        return StepsMissionScreen(
          missionSettings: missionSettings,
          onMissionComplete: onMissionComplete,
        );
      default:
        return Scaffold(
          appBar: AppBar(
            title: Text('Mission'),
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Unknown mission type: $missionType'),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onMissionComplete,
                  child: Text('Complete Mission'),
                ),
              ],
            ),
          ),
        );
    }
  }
}
