import 'package:flutter/material.dart';

import '../import/screen.dart';

/// ウォークスルー画面の構成ページ
enum WalkThroughContents {
  /// ウォークスルー画面の構成ページ
  welcomeScreen(WelcomeScreen()),

  /// メイン機能紹介ページ
  mainIntroductionScreen(MainIntroductionScreen()),

  /// サービス開始の案内ページ
  serviceBeginScreen(ServiceBeginScreen());

  const WalkThroughContents(
    this.widget,
  );

  /// ウォークスルー画面の構成ページ
  final Widget widget;
}
