// lib/features/alarm/providers/alarm_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_a/data/models/alarm_model.dart';
import 'package:project_a/core/services/alarm_service.dart';

class AlarmsNotifier extends StateNotifier<AsyncValue<List<AlarmModel>>> {
  AlarmsNotifier() : super(const AsyncValue.loading()) {
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    try {
      state = const AsyncValue.loading();
      final alarms = await AlarmService.getAlarms();
      state = AsyncValue.data(alarms);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    try {
      // Add to current state optimistically
      state.whenData((alarms) {
        state = AsyncValue.data([...alarms, alarm]);
      });

      // Save to persistent storage
      await AlarmService.saveAlarm(alarm);

      // Reload to ensure consistency
      await _loadAlarms();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    try {
      // Update in current state optimistically
      state.whenData((alarms) {
        final updatedAlarms =
            alarms.map((a) {
              return a.id == alarm.id ? alarm : a;
            }).toList();
        state = AsyncValue.data(updatedAlarms);
      });

      // Save to persistent storage
      await AlarmService.saveAlarm(alarm);

      // Reload to ensure consistency
      await _loadAlarms();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteAlarm(int id) async {
    try {
      // Remove from current state optimistically
      state.whenData((alarms) {
        final updatedAlarms = alarms.where((a) => a.id != id).toList();
        state = AsyncValue.data(updatedAlarms);
      });

      // Delete from persistent storage
      await AlarmService.deleteAlarm(id);

      // Reload to ensure consistency
      await _loadAlarms();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleAlarm(int id) async {
    try {
      // Toggle in current state optimistically
      late AlarmModel updatedAlarm;

      state.whenData((alarms) {
        final updatedAlarms =
            alarms.map((a) {
              if (a.id == id) {
                updatedAlarm = a.copyWith(isEnabled: !a.isEnabled);
                return updatedAlarm;
              }
              return a;
            }).toList();
        state = AsyncValue.data(updatedAlarms);
      });

      // Save to persistent storage
      await AlarmService.saveAlarm(updatedAlarm);

      // Reload to ensure consistency
      await _loadAlarms();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final alarmsProvider =
    StateNotifierProvider<AlarmsNotifier, AsyncValue<List<AlarmModel>>>((ref) {
      return AlarmsNotifier();
    });
