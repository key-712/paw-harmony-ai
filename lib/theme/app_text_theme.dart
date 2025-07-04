import 'package:flutter/material.dart';

import '../import/gen.dart';
import '../import/theme.dart';
import '../import/utility.dart';

/// アプリで利用する文字スタイルを管理するクラス
class AppTextTheme {
  /// インスタンスを作成します
  factory AppTextTheme(MediaType mediaType) {
    const normalRegular = TextStyle(
      fontFamily: FontFamily.notoSansJP,
      fontWeight: FontWeight.w400,
      height: 1.5,
      leadingDistribution: TextLeadingDistribution.even,
    );
    return AppTextTheme._(
      h8: mediaType == MediaType.sp
          ? const TextStyle(fontSize: FontSize.pt8).merge(normalRegular)
          : const TextStyle(fontSize: FontSize.pt10).merge(normalRegular),
      h10: mediaType == MediaType.sp
          ? const TextStyle(fontSize: FontSize.pt10).merge(normalRegular)
          : const TextStyle(fontSize: FontSize.pt12).merge(normalRegular),
      h20: mediaType == MediaType.sp
          ? const TextStyle(fontSize: FontSize.pt12).merge(normalRegular)
          : const TextStyle(fontSize: FontSize.pt14).merge(normalRegular),
      h30: mediaType == MediaType.sp
          ? const TextStyle(fontSize: FontSize.pt14).merge(normalRegular)
          : const TextStyle(fontSize: FontSize.pt16).merge(normalRegular),
      h40: mediaType == MediaType.sp
          ? const TextStyle(fontSize: FontSize.pt16).merge(normalRegular)
          : const TextStyle(fontSize: FontSize.pt18).merge(normalRegular),
      h45: mediaType == MediaType.sp
          ? const TextStyle(fontSize: FontSize.pt18).merge(normalRegular)
          : const TextStyle(fontSize: FontSize.pt20).merge(normalRegular),
      h50: mediaType == MediaType.sp
          ? const TextStyle(fontSize: FontSize.pt20).merge(normalRegular)
          : const TextStyle(fontSize: FontSize.pt22).merge(normalRegular),
      h60: mediaType == MediaType.sp
          ? const TextStyle(fontSize: FontSize.pt24).merge(normalRegular)
          : const TextStyle(fontSize: FontSize.pt26).merge(normalRegular),
      h70: mediaType == MediaType.sp
          ? const TextStyle(fontSize: FontSize.pt32).merge(normalRegular)
          : const TextStyle(fontSize: FontSize.pt34).merge(normalRegular),
      h80: mediaType == MediaType.sp
          ? const TextStyle(fontSize: FontSize.pt40).merge(normalRegular)
          : const TextStyle(fontSize: FontSize.pt42).merge(normalRegular),
    );
  }

  const AppTextTheme._({
    required this.h8,
    required this.h10,
    required this.h20,
    required this.h30,
    required this.h40,
    required this.h45,
    required this.h50,
    required this.h60,
    required this.h70,
    required this.h80,
  });

  /// pt8
  final TextStyle h8;

  /// pt10
  final TextStyle h10;

  /// pt12
  final TextStyle h20;

  /// pt14
  final TextStyle h30;

  /// pt16
  final TextStyle h40;

  /// pt18
  final TextStyle h45;

  /// pt20
  final TextStyle h50;

  /// pt24
  final TextStyle h60;

  /// pt32
  final TextStyle h70;

  /// pt40
  final TextStyle h80;
}

/// TextStyleクラスの拡張関数定義
extension TextStyleExt on TextStyle {
  /// 太字の文字スタイルで取得します
  TextStyle bold() => copyWith(fontWeight: FontWeight.w700);

  /// 中字の文字スタイルで取得します
  TextStyle medium() => copyWith(fontWeight: FontWeight.w500);
}
