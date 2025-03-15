// lib/features/alarm/screens/mission_selection_screen.dart
import 'package:flutter/material.dart';

class MissionSelectionScreen extends StatefulWidget {
  final String selectedMission;
  final Map<String, dynamic> missionSettings;

  const MissionSelectionScreen({
    Key? key,
    this.selectedMission = 'none',
    this.missionSettings = const {},
  }) : super(key: key);

  @override
  _MissionSelectionScreenState createState() => _MissionSelectionScreenState();
}

class _MissionSelectionScreenState extends State<MissionSelectionScreen> {
  late String _selectedMission;
  late Map<String, dynamic> _missionSettings;

  @override
  void initState() {
    super.initState();
    _selectedMission = widget.selectedMission;
    _missionSettings = Map.from(widget.missionSettings);
  }

  void _saveMission() {
    Navigator.pop(context, {
      'type': _selectedMission,
      'settings': _missionSettings,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Mission'),
        actions: [TextButton(onPressed: _saveMission, child: Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a mission to complete before turning off the alarm',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 24),

            // Mission options
            _buildMissionOption(
              'none',
              'No Mission',
              'Turn off alarm with a simple swipe',
              Icons.alarm_off,
              Colors.grey,
            ),
            _buildMissionOption(
              'math',
              'Math Problems',
              'Solve math equations to wake up your brain',
              Icons.calculate,
              Colors.blue,
            ),
            _buildMissionOption(
              'shake',
              'Shake',
              'Shake your phone to get your body moving',
              Icons.vibration,
              Colors.orange,
            ),
            _buildMissionOption(
              'photo',
              'Photo',
              'Take a photo of a specific location',
              Icons.camera_alt,
              Colors.purple,
            ),
            _buildMissionOption(
              'memory',
              'Memory Game',
              'Match pairs of cards to test your memory',
              Icons.grid_view,
              Colors.green,
            ),
            _buildMissionOption(
              'barcode',
              'Scan Barcode',
              'Scan a specific barcode to turn off the alarm',
              Icons.qr_code,
              Colors.red,
            ),
            _buildMissionOption(
              'steps',
              'Step Counter',
              'Take a number of steps to get you out of bed',
              Icons.directions_walk,
              Colors.teal,
            ),

            SizedBox(height: 24),

            // Mission settings
            if (_selectedMission != 'none') ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mission Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildMissionSettings(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMissionOption(
    String missionType,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedMission == missionType;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMission = missionType;

            // Initialize default settings for the mission type
            if (missionType == 'math' &&
                !_missionSettings.containsKey('difficulty')) {
              _missionSettings = {'difficulty': 'medium', 'count': 3};
            } else if (missionType == 'shake' &&
                !_missionSettings.containsKey('count')) {
              _missionSettings = {'count': 30, 'sensitivity': 'medium'};
            } else if (missionType == 'photo' &&
                !_missionSettings.containsKey('description')) {
              _missionSettings = {
                'description': 'bathroom sink',
                'hasReference': false,
              };
            } else if (missionType == 'memory' &&
                !_missionSettings.containsKey('pairs')) {
              _missionSettings = {'pairs': 6, 'timeLimit': 60};
            } else if (missionType == 'barcode' &&
                !_missionSettings.containsKey('description')) {
              _missionSettings = {'description': 'toothpaste', 'barcode': ''};
            } else if (missionType == 'steps' &&
                !_missionSettings.containsKey('count')) {
              _missionSettings = {'count': 20, 'sensitivity': 'medium'};
            }
          });
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: missionType,
                groupValue: _selectedMission,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMission = value;
                    });
                  }
                },
                activeColor: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionSettings() {
    switch (_selectedMission) {
      case 'math':
        return _buildMathSettings();
      case 'shake':
        return _buildShakeSettings();
      case 'photo':
        return _buildPhotoSettings();
      case 'memory':
        return _buildMemorySettings();
      case 'barcode':
        return _buildBarcodeSettings();
      case 'steps':
        return _buildStepsSettings();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildMathSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty'),
        SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'easy', label: Text('Easy')),
            ButtonSegment(value: 'medium', label: Text('Medium')),
            ButtonSegment(value: 'hard', label: Text('Hard')),
          ],
          selected: {_missionSettings['difficulty'] ?? 'medium'},
          onSelectionChanged: (Set<String> selection) {
            setState(() {
              _missionSettings['difficulty'] = selection.first;
            });
          },
        ),
        SizedBox(height: 16),
        Text('Number of Problems'),
        SizedBox(height: 8),
        Slider(
          value: (_missionSettings['count'] ?? 3).toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: (_missionSettings['count'] ?? 3).toString(),
          onChanged: (value) {
            setState(() {
              _missionSettings['count'] = value.toInt();
            });
          },
        ),
        Text(
          '${_missionSettings['count'] ?? 3} problems',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildShakeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number of Shakes'),
        SizedBox(height: 8),
        Slider(
          value: (_missionSettings['count'] ?? 30).toDouble(),
          min: 10,
          max: 100,
          divisions: 9,
          label: (_missionSettings['count'] ?? 30).toString(),
          onChanged: (value) {
            setState(() {
              _missionSettings['count'] = value.toInt();
            });
          },
        ),
        Text(
          '${_missionSettings['count'] ?? 30} shakes',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        SizedBox(height: 16),
        Text('Sensitivity'),
        SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'low', label: Text('Low')),
            ButtonSegment(value: 'medium', label: Text('Medium')),
            ButtonSegment(value: 'high', label: Text('High')),
          ],
          selected: {_missionSettings['sensitivity'] ?? 'medium'},
          onSelectionChanged: (Set<String> selection) {
            setState(() {
              _missionSettings['sensitivity'] = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPhotoSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'e.g., bathroom sink, coffee machine',
          ),
          initialValue: _missionSettings['description'] ?? '',
          onChanged: (value) {
            _missionSettings['description'] = value;
          },
        ),
        SizedBox(height: 16),
        SwitchListTile(
          title: Text('Use Reference Photo'),
          subtitle: Text('Take a photo now to match when alarm rings'),
          value: _missionSettings['hasReference'] ?? false,
          onChanged: (value) {
            setState(() {
              _missionSettings['hasReference'] = value;
            });
          },
        ),
        if (_missionSettings['hasReference'] == true) ...[
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // This would normally open the camera to take a reference photo
              // For now, we'll just simulate it
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Reference photo saved')));
              _missionSettings['referencePhotoTaken'] = true;
            },
            icon: Icon(Icons.camera_alt),
            label: Text('Take Reference Photo'),
          ),
        ],
      ],
    );
  }

  Widget _buildMemorySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number of Pairs'),
        SizedBox(height: 8),
        Slider(
          value: (_missionSettings['pairs'] ?? 6).toDouble(),
          min: 3,
          max: 12,
          divisions: 9,
          label: (_missionSettings['pairs'] ?? 6).toString(),
          onChanged: (value) {
            setState(() {
              _missionSettings['pairs'] = value.toInt();
            });
          },
        ),
        Text(
          '${_missionSettings['pairs'] ?? 6} pairs',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        SizedBox(height: 16),
        Text('Time Limit (seconds)'),
        SizedBox(height: 8),
        Slider(
          value: (_missionSettings['timeLimit'] ?? 60).toDouble(),
          min: 30,
          max: 180,
          divisions: 5,
          label: (_missionSettings['timeLimit'] ?? 60).toString(),
          onChanged: (value) {
            setState(() {
              _missionSettings['timeLimit'] = value.toInt();
            });
          },
        ),
        Text(
          '${_missionSettings['timeLimit'] ?? 60} seconds',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildBarcodeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'e.g., toothpaste, cereal box',
          ),
          initialValue: _missionSettings['description'] ?? '',
          onChanged: (value) {
            _missionSettings['description'] = value;
          },
        ),
        SizedBox(height: 16),
        SwitchListTile(
          title: Text('Register Specific Barcode'),
          subtitle: Text('Scan a barcode now to use when alarm rings'),
          value:
              _missionSettings['barcode'] != null &&
              _missionSettings['barcode'].isNotEmpty,
          onChanged: (value) {
            if (value) {
              // This would normally open the barcode scanner
              // For now, we'll just simulate it
              _missionSettings['barcode'] = 'SAMPLE_BARCODE_123456789';
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Barcode registered')));
            } else {
              _missionSettings['barcode'] = '';
            }
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildStepsSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number of Steps'),
        SizedBox(height: 8),
        Slider(
          value: (_missionSettings['count'] ?? 20).toDouble(),
          min: 10,
          max: 100,
          divisions: 9,
          label: (_missionSettings['count'] ?? 20).toString(),
          onChanged: (value) {
            setState(() {
              _missionSettings['count'] = value.toInt();
            });
          },
        ),
        Text(
          '${_missionSettings['count'] ?? 20} steps',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        SizedBox(height: 16),
        Text('Sensitivity'),
        SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'low', label: Text('Low')),
            ButtonSegment(value: 'medium', label: Text('Medium')),
            ButtonSegment(value: 'high', label: Text('High')),
          ],
          selected: {_missionSettings['sensitivity'] ?? 'medium'},
          onSelectionChanged: (Set<String> selection) {
            setState(() {
              _missionSettings['sensitivity'] = selection.first;
            });
          },
        ),
      ],
    );
  }
}
