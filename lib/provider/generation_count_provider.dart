import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utility/const/shared_preferences_keys.dart';

final generationCountProvider = StateNotifierProvider<GenerationCountNotifier, int>((ref) {
  return GenerationCountNotifier();
});

class GenerationCountNotifier extends StateNotifier<int> {
  GenerationCountNotifier() : super(3) {
    _load();
  }

  static const int maxGenerations = 3;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lastGenerationDate = prefs.getString(SharedPreferencesKeys.lastGenerationDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastGenerationDate == today) {
      state = prefs.getInt(SharedPreferencesKeys.generationCountKey) ?? maxGenerations;
    } else {
      await prefs.setInt(SharedPreferencesKeys.generationCountKey, maxGenerations);
      await prefs.setString(SharedPreferencesKeys.lastGenerationDateKey, today);
      state = maxGenerations;
    }
  }

  Future<void> decrement() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(SharedPreferencesKeys.lastGenerationDateKey, today);

    if (state > 0) {
      state = state - 1;
      await prefs.setInt(SharedPreferencesKeys.generationCountKey, state);
    }
  }

  Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    if (state < maxGenerations) {
      state = state + 1;
      await prefs.setInt(SharedPreferencesKeys.generationCountKey, state);
    }
  }
}
