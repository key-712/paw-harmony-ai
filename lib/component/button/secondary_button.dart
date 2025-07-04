import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/type.dart';
import '../../import/widgetbook.dart';

/// ボタン(強調度：中)
class SecondaryButton extends ConsumerWidget {
  /// ボタン(強調度：中)
  const SecondaryButton({
    super.key,
    required this.text,
    required this.screen,
    required this.width,
    required this.isDisabled,
    required this.callback,
    this.height,
  });

  /// テキスト
  final String text;

  /// 画面
  final String screen;

  /// 幅
  final double width;

  /// 無効化
  final bool isDisabled;

  /// コールバック
  final VoidCallback callback;

  /// 高さ
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return SizedBox(
      height: height ?? ButtonStyles.buttonHeight,
      width: width,
      child: OutlinedButton(
        onPressed: isDisabled
            ? null
            : () async {
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
          disabledBackgroundColor: theme.appColors.main,
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
          style: theme.textTheme.h40.bold(),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'SecondaryButton',
  type: SecondaryButton,
)

/// SecondaryButtonウィジェットのWidgetbookでの確認用メソッド
Widget secondaryButtonUseCase(BuildContext context) {
  final text =
      useStringKnob(context: context, label: 'Title', initialValue: 'ボタン');
  const isDisabled = false;
  Future<void> callback() async {}

  return SecondaryButton(
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
    screen: 'hogehoge画面',
  );
}
