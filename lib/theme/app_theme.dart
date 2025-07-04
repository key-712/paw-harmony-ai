import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/gen.dart';
import '../import/provider.dart';
import '../import/theme.dart';
import '../import/utility.dart';

export 'app_text_theme.dart' show TextStyleExt;

/// アプリのテーマの更新通知を管理するプロバイダ
final appThemeModeProvider =
    StateNotifierProvider<StateController<ThemeMode>, ThemeMode>(
  // OSのテーマモードに依存させる場合は、ThemeMode.systemに変更する
  (ref) => StateController(ThemeMode.light),
);

/// アプリのテーマを管理するプロバイダ
final appThemeProvider = Provider<AppTheme>(
  (ref) {
    final mode = ref.watch(appThemeModeProvider);
    final mediaQuery = ref.watch(mediaQueryStateNotifierProvider);
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    switch (mode) {
      case ThemeMode.dark:
        return AppTheme.dark(mediaQuery);
      case ThemeMode.light:
        return AppTheme.light(mediaQuery);
      case ThemeMode.system:
        switch (brightness) {
          case Brightness.light:
            return AppTheme.light(mediaQuery);
          case Brightness.dark:
            return AppTheme.dark(mediaQuery);
        }
    }
  },
);

/// アプリテーマを管理するクラス
class AppTheme {
  /// インスタンスを作成します
  AppTheme({
    required this.mode,
    required this.data,
    required this.textTheme,
    required this.appColors,
  });

  /// ライトテーマ用のアプリテーマインスタンスを作成します
  factory AppTheme.light(MediaType mediaType) {
    const mode = ThemeMode.light;
    final textTheme = AppTextTheme(mediaType);
    final appColors = AppColors.light();
    final themeData = ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ColorName.main,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ColorName.main,
        selectedLabelStyle: textTheme.h10,
        unselectedItemColor: Colors.black.withValues(alpha: 0.3),
        unselectedLabelStyle: textTheme.h10,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: ThemeData.light().textTheme,
    );
    return AppTheme(
      mode: mode,
      data: themeData,
      textTheme: textTheme,
      appColors: appColors,
    );
  }

  /// ダークテーマ用のアプリテーマインスタンスを作成します
  factory AppTheme.dark(MediaType mediaType) {
    const mode = ThemeMode.dark;
    final textTheme = AppTextTheme(mediaType);
    final appColors = AppColors.dark();
    final themeData = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: ColorName.main,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ColorName.main,
        selectedLabelStyle: textTheme.h10,
        unselectedItemColor: Colors.black.withValues(alpha: 0.3),
        unselectedLabelStyle: textTheme.h10,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: ThemeData.dark().textTheme,
    );
    return AppTheme(
      mode: mode,
      data: themeData,
      textTheme: textTheme,
      appColors: appColors,
    );
  }

  /// テーマモード
  final ThemeMode mode;

  /// テーマデータ
  final ThemeData data;

  /// テキストテーマ
  final AppTextTheme textTheme;

  /// アプリカラー
  final AppColors appColors;
}
