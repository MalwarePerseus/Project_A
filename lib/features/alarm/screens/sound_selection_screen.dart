// lib/features/alarm/screens/sound_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundSelectionScreen extends StatefulWidget {
  final String selectedSound;

  const SoundSelectionScreen({Key? key, this.selectedSound = 'default_alarm'})
    : super(key: key);

  @override
  _SoundSelectionScreenState createState() => _SoundSelectionScreenState();
}

class _SoundSelectionScreenState extends State<SoundSelectionScreen> {
  late String _selectedSound;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingSound;

  final List<Map<String, dynamic>> _sounds = [
    {
      'id': 'default_alarm',
      'name': 'Default Alarm',
      'category': 'Energetic',
      'icon': Icons.alarm,
    },
    {
      'id': 'gentle_chime',
      'name': 'Gentle Chime',
      'category': 'Gentle',
      'icon': Icons.notifications,
    },
    {
      'id': 'morning_birds',
      'name': 'Morning Birds',
      'category': 'Nature',
      'icon': Icons.nature,
    },
    {
      'id': 'energetic_beats',
      'name': 'Energetic Beats',
      'category': 'Energetic',
      'icon': Icons.music_note,
    },
    {
      'id': 'digital_beep',
      'name': 'Digital Beep',
      'category': 'Energetic',
      'icon': Icons.alarm,
    },
    {
      'id': 'soft_piano',
      'name': 'Soft Piano',
      'category': 'Gentle',
      'icon': Icons.piano,
    },
    {
      'id': 'ocean_waves',
      'name': 'Ocean Waves',
      'category': 'Nature',
      'icon': Icons.waves,
    },
    {
      'id': 'rooster',
      'name': 'Rooster',
      'category': 'Nature',
      'icon': Icons.nature_people,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.selectedSound;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String soundId) async {
    if (_playingSound != null) {
      await _audioPlayer.stop();
    }

    // In a real app, you would load the actual sound file
    // For this example, we'll just simulate playing
    await _audioPlayer.play(AssetSource('sounds/$soundId.mp3'));
    setState(() {
      _playingSound = soundId;
    });
  }

  Future<void> _stopSound() async {
    await _audioPlayer.stop();
    setState(() {
      _playingSound = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Sound'),
        actions: [
          TextButton(
            onPressed: () {
              _stopSound();
              Navigator.pop(context, _selectedSound);
            },
            child: Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category tabs
          Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('All', true),
                  SizedBox(width: 8),
                  _buildCategoryChip('Gentle', false),
                  SizedBox(width: 8),
                  _buildCategoryChip('Energetic', false),
                  SizedBox(width: 8),
                  _buildCategoryChip('Nature', false),
                ],
              ),
            ),
          ),

          // Sound list
          Expanded(
            child: ListView.builder(
              itemCount: _sounds.length,
              itemBuilder: (context, index) {
                final sound = _sounds[index];
                final isSelected = _selectedSound == sound['id'];
                final isPlaying = _playingSound == sound['id'];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: isSelected ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        sound['icon'],
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(sound['name']),
                    subtitle: Text(sound['category']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                          onPressed: () {
                            if (isPlaying) {
                              _stopSound();
                            } else {
                              _playSound(sound['id']);
                            }
                          },
                        ),
                        Radio<String>(
                          value: sound['id'],
                          groupValue: _selectedSound,
                          onChanged: (value) {
                            setState(() {
                              _selectedSound = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedSound = sound['id'];
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        // In a real app, you would filter the sounds by category
      },
    );
  }
}
