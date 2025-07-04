import 'package:flutter/material.dart';

import '../import/gen.dart';

/// アプリで利用する色情報を管理するクラス
class AppColors {
  /// アプリで利用する色情報を管理するクラス
  const AppColors({
    required this.main,
    required this.primary,
    required this.background,
    required this.white,
    required this.black,
    required this.grey,
    required this.red,
    required this.yellow,
    required this.orange,
    required this.green,
    required this.blue,
    required this.blueGray,
    required this.purple,
    required this.activeDotColor,
    required this.loading,
    required this.progress,
  });

  /// ライトテーマ用の色情報を管理インスタンスを作成します
  factory AppColors.light() {
    return const AppColors(
      main: ColorName.main,
      primary: ColorName.primary,
      background: ColorName.backGround,
      white: Colors.white,
      black: Colors.black,
      grey: Colors.grey,
      red: Colors.redAccent,
      yellow: Colors.amber,
      orange: Colors.orange,
      green: Colors.green,
      blue: Colors.blue,
      blueGray: ColorName.blueGrey,
      purple: Colors.purple,
      activeDotColor: Colors.white38,
      loading: Colors.white,
      progress: ColorName.progress,
    );
  }

  /// ダークテーマ用の色情報を管理インスタンスを作成します
  factory AppColors.dark() {
    return const AppColors(
      main: ColorName.main,
      primary: ColorName.primary,
      background: ColorName.backGround,
      white: Colors.white,
      black: Colors.black,
      grey: Colors.grey,
      red: Colors.redAccent,
      yellow: Colors.amber,
      orange: Colors.orange,
      green: Colors.green,
      blue: Colors.blue,
      blueGray: ColorName.blueGrey,
      purple: Colors.purple,
      activeDotColor: Colors.white38,
      loading: Colors.white,
      progress: ColorName.progress,
    );
  }

  /// メインカラー
  final Color main;

  /// プライマリーカラー
  final Color primary;

  /// 背景カラー
  final Color background;

  /// 白
  final Color white;

  /// 黒
  final Color black;

  /// グレー
  final Color grey;

  /// 赤
  final Color red;

  /// 黄色
  final Color yellow;

  /// 橙
  final Color orange;

  /// 緑
  final Color green;

  /// 青
  final Color blue;

  /// 青グレー
  final Color blueGray;

  /// 紫
  final Color purple;

  /// アクティブドットカラー
  final Color activeDotColor;

  /// ローディングカラー
  final Color loading;

  /// プログレスカラー
  final Color progress;
}
