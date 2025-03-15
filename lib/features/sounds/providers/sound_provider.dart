// lib/features/sounds/providers/sound_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Sound {
  final String id;
  final String name;
  final String category;
  final String imageAsset;
  final String audioAsset;
  final bool isPremium;

  Sound({
    required this.id,
    required this.name,
    required this.category,
    required this.imageAsset,
    required this.audioAsset,
    this.isPremium = false,
  });
}

class SoundsNotifier extends StateNotifier<AsyncValue<List<Sound>>> {
  SoundsNotifier() : super(const AsyncValue.loading()) {
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    try {
      // In a real app, this would load from an API or local database
      // For this example, we'll use a hardcoded list
      await Future.delayed(Duration(milliseconds: 500)); // Simulate loading

      final sounds = [
        Sound(
          id: 'rain',
          name: 'Gentle Rain',
          category: 'nature',
          imageAsset: 'rain.jpg',
          audioAsset: 'rain.mp3',
        ),
        Sound(
          id: 'forest',
          name: 'Forest Ambience',
          category: 'nature',
          imageAsset: 'forest.jpg',
          audioAsset: 'forest.mp3',
        ),
        Sound(
          id: 'ocean',
          name: 'Ocean Waves',
          category: 'nature',
          imageAsset: 'ocean.jpg',
          audioAsset: 'ocean.mp3',
        ),
        Sound(
          id: 'thunderstorm',
          name: 'Thunderstorm',
          category: 'nature',
          imageAsset: 'thunderstorm.jpg',
          audioAsset: 'thunderstorm.mp3',
          isPremium: true,
        ),
        Sound(
          id: 'fire',
          name: 'Crackling Fire',
          category: 'nature',
          imageAsset: 'fire.jpg',
          audioAsset: 'fire.mp3',
        ),
        Sound(
          id: 'birds',
          name: 'Morning Birds',
          category: 'nature',
          imageAsset: 'birds.jpg',
          audioAsset: 'birds.mp3',
        ),
        Sound(
          id: 'white_noise',
          name: 'White Noise',
          category: 'white_noise',
          imageAsset: 'white_noise.jpg',
          audioAsset: 'white_noise.mp3',
        ),
        Sound(
          id: 'brown_noise',
          name: 'Brown Noise',
          category: 'white_noise',
          imageAsset: 'brown_noise.jpg',
          audioAsset: 'brown_noise.mp3',
        ),
        Sound(
          id: 'pink_noise',
          name: 'Pink Noise',
          category: 'white_noise',
          imageAsset: 'pink_noise.jpg',
          audioAsset: 'pink_noise.mp3',
          isPremium: true,
        ),
        Sound(
          id: 'fan',
          name: 'Fan Sound',
          category: 'white_noise',
          imageAsset: 'fan.jpg',
          audioAsset: 'fan.mp3',
        ),
        Sound(
          id: 'asmr_tapping',
          name: 'Gentle Tapping',
          category: 'asmr',
          imageAsset: 'tapping.jpg',
          audioAsset: 'tapping.mp3',
        ),
        Sound(
          id: 'asmr_whisper',
          name: 'Soft Whispers',
          category: 'asmr',
          imageAsset: 'whisper.jpg',
          audioAsset: 'whisper.mp3',
          isPremium: true,
        ),
        Sound(
          id: 'asmr_pages',
          name: 'Page Turning',
          category: 'asmr',
          imageAsset: 'pages.jpg',
          audioAsset: 'pages.mp3',
        ),
        Sound(
          id: 'asmr_writing',
          name: 'Writing Sounds',
          category: 'asmr',
          imageAsset: 'writing.jpg',
          audioAsset: 'writing.mp3',
          isPremium: true,
        ),
      ];

      state = AsyncValue.data(sounds);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final soundsProvider =
    StateNotifierProvider<SoundsNotifier, AsyncValue<List<Sound>>>((ref) {
      return SoundsNotifier();
    });

// Provider to track currently playing sound
final currentlyPlayingSoundIdProvider = StateProvider<String?>((ref) => null);

// Provider for premium status (would be connected to actual subscription service)
final isPremiumUserProvider = StateProvider<bool>((ref) => false);
