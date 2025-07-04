import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/gen.dart';
import '../../import/theme.dart';
import '../../import/widgetbook.dart';

/// リンクなしテキスト(デザインカスタム可)
class ThemeText extends ConsumerWidget {
  /// リンクなしテキスト(デザインカスタム可)
  const ThemeText({
    super.key,
    required this.text,
    required this.color,
    required this.style,
    this.align,
    this.decoration,
    this.overflow = TextOverflow.visible,
  });

  /// テキスト
  final String text;

  /// 色
  final Color color;

  /// スタイル
  final TextStyle style;

  /// 配置
  final TextAlign? align;

  /// 装飾
  final TextDecoration? decoration;

  /// オーバーフロー
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newStyle = style.copyWith(color: color, decoration: decoration);
    return Text(
      text,
      style: newStyle,
      textAlign: align ?? TextAlign.start,
      overflow: overflow,
    );
  }
}

/// ThemeTextウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(name: 'ThemeText', type: ThemeText)
Widget themeTextUseCase(BuildContext context) {
  final text = useStringKnob(
    context: context,
    label: 'ThemeText',
    initialValue: 'テキスト',
  );
  const normalRegular = TextStyle(
    fontFamily: FontFamily.notoSansJP,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  return ThemeText(
    text: text,
    color: useListKnob(
      context: context,
      label: 'color',
      options: [Colors.black, const Color(0xFFF75D19), Colors.white],
    ),
    style: const TextStyle(fontSize: FontSize.pt16).merge(normalRegular),
  );
}
