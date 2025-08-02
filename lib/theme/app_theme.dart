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
final appThemeProvider = Provider<AppTheme>((ref) {
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
});

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
      scaffoldBackgroundColor: ColorName.backGround,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorName.backGround,
        foregroundColor: ColorName.main,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ColorName.main,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ColorName.main,
        selectedLabelStyle: textTheme.h10,
        unselectedItemColor: ColorName.secondary,
        unselectedLabelStyle: textTheme.h10,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: ThemeData.light().textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorName.main,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
      scaffoldBackgroundColor: ColorName.secondary,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorName.secondary,
        foregroundColor: ColorName.main,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ColorName.main,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ColorName.secondary,
        selectedItemColor: ColorName.main,
        selectedLabelStyle: textTheme.h10,
        unselectedItemColor: Colors.white70,
        unselectedLabelStyle: textTheme.h10,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: ThemeData.dark().textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorName.main,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: ColorName.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
