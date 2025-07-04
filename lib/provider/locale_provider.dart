import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';

/// アプリ全体のロケールを管理するプロバイダー
final localeProvider = StateProvider<Locale?>((ref) {
  // デバイスのロケールを取得して、初期ロケールを設定
  final deviceLocale = PlatformDispatcher.instance.locale;
  if (deviceLocale.languageCode == 'ja') {
    return const Locale('ja');
  }
  return const Locale('en');
});

/// ロケールの設定を行うための拡張メソッド
extension LocaleNotifier on StateController<Locale?> {
  /// ロケールを設定します
  set locale(Locale locale) {
    state = locale;
  }
}
