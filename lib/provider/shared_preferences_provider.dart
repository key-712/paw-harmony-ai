import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferencesクラスのインスタンスを管理するプロバイダ
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnsupportedError(
    'SharedPreferences instance has not been created.',
  ),
);
