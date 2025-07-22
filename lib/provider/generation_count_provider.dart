import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../import/utility.dart';

/// 音声生成回数のProvider
final generationCountProvider =
    StateNotifierProvider<GenerationCountNotifier, int>((ref) {
      return GenerationCountNotifier();
    });

/// 音声生成回数のNotifier
class GenerationCountNotifier extends StateNotifier<int> {
  /// 音声生成回数のNotifierのコンストラクタ
  GenerationCountNotifier() : super(3) {
    _load();
  }

  /// 音声生成回数の最大値
  static const maxGenerations = 3;

  /// 音声生成回数を読み込む
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lastGenerationDate = prefs.getString(
      SharedPreferencesKeys.lastGenerationDateKey,
    );
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastGenerationDate == today) {
      state =
          prefs.getInt(SharedPreferencesKeys.generationCountKey) ??
          maxGenerations;
    } else {
      await prefs.setInt(
        SharedPreferencesKeys.generationCountKey,
        maxGenerations,
      );
      await prefs.setString(SharedPreferencesKeys.lastGenerationDateKey, today);
      state = maxGenerations;
    }
  }

  /// 音声生成回数を減らす
  Future<void> decrement() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(SharedPreferencesKeys.lastGenerationDateKey, today);

    if (state > 0) {
      state = state - 1;
      await prefs.setInt(SharedPreferencesKeys.generationCountKey, state);
    }
  }

  /// 音声生成回数を増やす
  Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    if (state < maxGenerations) {
      state = state + 1;
      await prefs.setInt(SharedPreferencesKeys.generationCountKey, state);
    }
  }
}
