// lib/features/sounds/screens/sound_library_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/features/sounds/providers/sound_provider.dart';
import 'package:project_a/features/sounds/screens/sound_player_screen.dart';
import 'package:project_a/features/subscription/screens/subscription_screen.dart';

class SoundLibraryScreen extends ConsumerStatefulWidget {
  @override
  _SoundLibraryScreenState createState() => _SoundLibraryScreenState();
}

class _SoundLibraryScreenState extends ConsumerState<SoundLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused soundsAsync variable

    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Sounds'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Nature'),
            Tab(text: 'ASMR'),
            Tab(text: 'White Noise'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSoundList(context, 'all'),
          _buildSoundList(context, 'nature'),
          _buildSoundList(context, 'asmr'),
          _buildSoundList(context, 'white_noise'),
        ],
      ),
    );
  }

  Widget _buildSoundList(BuildContext context, String category) {
    final soundsAsync = ref.watch(soundsProvider);

    return soundsAsync.when(
      data: (sounds) {
        // Filter sounds by category
        final filteredSounds =
            category == 'all'
                ? sounds
                : sounds.where((sound) => sound.category == category).toList();

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filteredSounds.length,
          itemBuilder: (context, index) {
            final sound = filteredSounds[index];
            return _buildSoundCard(context, sound);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(child: Text('Error loading sounds: $error')),
    );
  }

  Widget _buildSoundCard(BuildContext context, Sound sound) {
    final isPremium = sound.isPremium;
    final isCurrentlyPlaying =
        ref.watch(currentlyPlayingSoundIdProvider) == sound.id;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (isPremium && !ref.read(isPremiumUserProvider)) {
            _showPremiumDialog();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SoundPlayerScreen(sound: sound),
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/sounds/${sound.imageAsset}',
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(179), // Fixed: 0.7 * 255 ≈ 179
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    sound.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(sound.category),
                        color: Colors.white.withAlpha(
                          204,
                        ), // Fixed: 0.8 * 255 ≈ 204
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        _getCategoryName(sound.category),
                        style: TextStyle(
                          color: Colors.white.withAlpha(
                            204,
                          ), // Fixed: 0.8 * 255 ≈ 204
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Play indicator
            if (isCurrentlyPlaying)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 16),
                ),
              ),
            // Premium badge
            if (isPremium)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'nature':
        return Icons.nature;
      case 'asmr':
        return Icons.surround_sound;
      case 'white_noise':
        return Icons.waves;
      default:
        return Icons.music_note;
    }
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

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Premium Feature'),
            content: Text('This sound is only available for premium users.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionScreen(),
                    ),
                  );
                },
                child: Text('Get Premium'),
              ),
            ],
          ),
    );
  }
}
