import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/utility.dart';

/// ホーム画面(表示パターン1画面)が初めてアクセスされたかどうかの状態を管理するプロバイダ
final isInitialHomeProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final isInitialHome =
      prefs.getBool(SharedPreferencesKeys.initialHomeKey) ?? true;
  if (isInitialHome) {
    prefs.setBool(SharedPreferencesKeys.initialHomeKey, false);
  }
  return isInitialHome;
});
