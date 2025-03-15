// lib/features/sleep_tracking/providers/sleep_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/data/models/sleep_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SleepDataNotifier extends StateNotifier<AsyncValue<List<SleepData>>> {
  SleepDataNotifier() : super(const AsyncValue.loading()) {
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    try {
      state = const AsyncValue.loading();
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList('sleep_data') ?? [];

      final sleepData =
          jsonList
              .map((jsonString) => SleepData.fromJson(jsonDecode(jsonString)))
              .toList();

      state = AsyncValue.data(sleepData);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addSleepData(SleepData sleepData) async {
    try {
      // Add to current state optimistically
      state.whenData((data) {
        state = AsyncValue.data([...data, sleepData]);
      });

      // Save to persistent storage
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList('sleep_data') ?? [];

      jsonList.add(jsonEncode(sleepData.toJson()));
      await prefs.setStringList('sleep_data', jsonList);

      // Reload to ensure consistency
      await _loadSleepData();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteSleepData(String id) async {
    try {
      // Remove from current state optimistically
      state.whenData((data) {
        final updatedData = data.where((item) => item.id != id).toList();
        state = AsyncValue.data(updatedData);
      });

      // Update persistent storage
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList('sleep_data') ?? [];

      final updatedJsonList =
          jsonList.where((jsonString) {
            final data = jsonDecode(jsonString);
            return data['id'] != id;
          }).toList();

      await prefs.setStringList('sleep_data', updatedJsonList);

      // Reload to ensure consistency
      await _loadSleepData();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final sleepDataProvider =
    StateNotifierProvider<SleepDataNotifier, AsyncValue<List<SleepData>>>((
      ref,
    ) {
      return SleepDataNotifier();
    });
