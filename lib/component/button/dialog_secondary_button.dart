import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/type.dart';
import '../../import/widgetbook.dart';

/// ダイアログのボタン(強調度：中)
class DialogSecondaryButton extends ConsumerWidget {
  /// ダイアログのボタン(強調度：中)
  const DialogSecondaryButton({
    super.key,
    required this.text,
    required this.screen,
    required this.width,
    required this.callback,
  });

  /// ボタンのテキスト
  final String text;

  /// ボタンが表示される画面
  final String screen;

  /// ボタンの幅
  final double width;

  /// ボタンがタップされた時のコールバック
  final VoidCallback callback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return SizedBox(
      height: ButtonStyles.dialogButtonHeight,
      width: width,
      child: OutlinedButton(
        onPressed: () async {
          await ref.read(firebaseAnalyticsServiceProvider).tapButton(
                parameters: TapButtonLog(
                  screen: screen,
                  label: text,
                ),
              );
          callback();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.appColors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(ButtonStyles.buttonBorderRadius),
          ),
          side: BorderSide(
            color: theme.appColors.main,
          ),
        ),
        child: ThemeText(
          text: text,
          color: theme.appColors.main,
          style: theme.textTheme.h20.bold(),
        ),
      ),
    );
  }
}

/// DialogSecondaryButtonウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(
  name: 'DialogSecondaryButton',
  type: DialogSecondaryButton,
)
Widget dialogSecondaryButtonUseCase(BuildContext context) {
  final text =
      useStringKnob(context: context, label: 'Title', initialValue: 'ボタン');
  Future<void> callback() async {}

  return DialogSecondaryButton(
    text: text,
    width: useSliderKnob(
      context: context,
      label: 'Width',
      initialValue: 200,
      max: 1000,
      divisions: 100,
    ),
    callback: callback,
    screen: 'screen',
  );
}
