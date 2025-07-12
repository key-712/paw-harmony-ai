import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/type.dart';
import '../../import/widgetbook.dart';

/// ボタン(強調度：高)
class PrimaryButton extends ConsumerWidget {
  /// ボタン(強調度：高)
  const PrimaryButton({
    super.key,
    required this.text,
    required this.screen,
    required this.width,
    required this.isDisabled,
    required this.callback,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return SizedBox(
      height: ButtonStyles.buttonHeight,
      width: width,
      child: OutlinedButton(
        onPressed:
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
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.appColors.main.withValues(alpha: 0.8),
          disabledBackgroundColor: theme.appColors.white.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ButtonStyles.buttonBorderRadius,
            ),
          ),
          side: BorderSide(color: theme.appColors.main),
        ),
        child: ThemeText(
          text: text,
          color: isDisabled ? theme.appColors.main : theme.appColors.white,
          style: theme.textTheme.h40.bold(),
        ),
      ),
    );
  }
}

/// PrimaryButtonウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(name: 'PrimaryButton', type: PrimaryButton)
Widget primaryButtonUseCase(BuildContext context) {
  final text = useStringKnob(
    context: context,
    label: 'Title',
    initialValue: 'ボタン',
  );
  const isDisabled = false;
  Future<void> callback() async {}

  return PrimaryButton(
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
