import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/type.dart';
import '../../import/widgetbook.dart';

/// キャンセルボタン
class CancelButton extends ConsumerWidget {
  /// キャンセルボタン
  const CancelButton({
    super.key,
    required this.text,
    required this.screen,
    required this.width,
    required this.isDisabled,
    required this.callback,
    this.height,
  });

  /// ボタンのテキスト
  final String text;

  /// ボタンが表示される画面
  final String screen;

  /// ボタンの幅
  final double width;

  /// ボタンが無効かどうか
  final bool isDisabled;

  /// ボタンがタップされた時のコールバック
  final VoidCallback callback;

  /// ボタンの高さ
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return GestureDetector(
      onTap:
          isDisabled
              ? null
              : () async {
                await ref
                    .read(firebaseAnalyticsServiceProvider)
                    .tapButton(
                      parameters: TapButtonLog(screen: screen, label: text),
                    );
                callback();
              },
      child: Container(
        height: height ?? ButtonStyles.buttonHeight,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.appColors.white,
          border: Border.all(color: theme.appColors.grey),
          borderRadius: BorderRadius.circular(ButtonStyles.buttonBorderRadius),
        ),
        child: ThemeText(
          text: text,
          color: theme.appColors.grey,
          style: theme.textTheme.h40.bold(),
        ),
      ),
    );
  }
}

/// CancelButtonウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(name: 'CancelButton', type: CancelButton)
Widget cancelButtonUseCase(BuildContext context) {
  final text = useStringKnob(
    context: context,
    label: 'Title',
    initialValue: 'ボタン',
  );
  const isDisabled = false;
  void callback() {}

  return CancelButton(
    text: text,
    width: useSliderKnob(
      context: context,
      label: 'Width',
      initialValue: 200,
      max: 1000,
      divisions: 100,
    ),
    isDisabled: isDisabled,
    callback: callback,
    screen: 'screen',
  );
}
