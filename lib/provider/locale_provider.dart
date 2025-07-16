import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';

/// アプリ全体のロケールを管理するプロバイダー
final localeProvider = StateProvider<Locale?>((ref) {
  // デバイスのロケールを取得して、初期ロケールを設定
  final deviceLocale = PlatformDispatcher.instance.locale;
  final languageCode = deviceLocale.languageCode;

  if (languageCode == 'ja') {
    return const Locale('ja');
  } else if (languageCode == 'fr') {
    return const Locale('fr');
  } else if (languageCode == 'it') {
    return const Locale('it');
  } else if (languageCode == 'es') {
    return const Locale('es');
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
