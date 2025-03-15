// lib/features/sounds/screens/sound_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/features/sounds/providers/sound_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class SoundPlayerScreen extends ConsumerStatefulWidget {
  final Sound sound;

  const SoundPlayerScreen({Key? key, required this.sound}) : super(key: key);

  @override
  _SoundPlayerScreenState createState() => _SoundPlayerScreenState();
}

class _SoundPlayerScreenState extends ConsumerState<SoundPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _volume = 0.7;
  int _timerMinutes = 30;
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _playSound();

    // Set timer
    _remainingSeconds = _timerMinutes * 60;
    _startTimer();

    // Update currently playing sound
    ref.read(currentlyPlayingSoundIdProvider.notifier).state = widget.sound.id;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();

    // Clear currently playing sound if it's this one
    if (ref.read(currentlyPlayingSoundIdProvider) == widget.sound.id) {
      ref.read(currentlyPlayingSoundIdProvider.notifier).state = null;
    }

    super.dispose();
  }

  Future<void> _playSound() async {
    // In a real app, you would load the actual sound file
    // For this example, we'll just simulate playing
    await _audioPlayer.play(AssetSource('sounds/${widget.sound.audioAsset}'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(_volume);

    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _pauseSound() async {
    await _audioPlayer.pause();

    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _resumeSound() async {
    await _audioPlayer.resume();

    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);

    setState(() {
      _volume = volume;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _pauseSound();
        }
      });
    });
  }

  void _setTimer(int minutes) {
    _timer?.cancel();

    setState(() {
      _timerMinutes = minutes;
      _remainingSeconds = minutes * 60;
    });

    if (_isPlaying) {
      _startTimer();
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/sounds/${widget.sound.imageAsset}',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {
                        // Add to favorites
                      },
                    ),
                  ],
                ),
              ),
              Spacer(),
              // Sound info and controls
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sound.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _getCategoryName(widget.sound.category),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 32),
                    // Timer display
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Timer',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _formatDuration(_remainingSeconds),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    // Timer options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimerChip(15),
                        _buildTimerChip(30),
                        _buildTimerChip(60),
                        _buildTimerChip(120),
                        _buildTimerChip(0, label: '∞'),
                      ],
                    ),
                    SizedBox(height: 32),
                    // Volume control
                    Row(
                      children: [
                        Icon(
                          _volume == 0
                              ? Icons.volume_off
                              : _volume < 0.5
                              ? Icons.volume_down
                              : Icons.volume_up,
                          color: Colors.white,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Slider(
                            value: _volume,
                            onChanged: _setVolume,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    // Play/pause button
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (_isPlaying) {
                            _pauseSound();
                          } else {
                            _resumeSound();
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 48,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerChip(int minutes, {String? label}) {
    final isSelected = _timerMinutes == minutes;

    return GestureDetector(
      onTap: () {
        _setTimer(minutes);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label ?? '$minutes min',
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'nature':
        return 'Nature';
      case 'asmr':
        return 'ASMR';
      case 'white_noise':
        return 'White Noise';
      default:
        return 'Unknown';
    }
  }
}
