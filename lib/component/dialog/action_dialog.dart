import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../import/widgetbook.dart';

/// ボタンが一つのダイアログ
class ActionDialog extends ConsumerWidget {
  /// ボタンが一つのダイアログ
  const ActionDialog({
    super.key,
    required this.title,
    required this.screen,
    required this.content,
    required this.buttonLabel,
    required this.callBack,
  });

  /// タイトル
  final String title;

  /// 画面
  final String screen;

  /// 内容
  final String content;

  /// ボタンラベル
  final String buttonLabel;

  /// コールバック
  final VoidCallback callBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: SizedBox(
        width: double.infinity,
        child: ThemeText(
          text: title,
          color: theme.appColors.black,
          style: theme.textTheme.h50.bold(),
          align: TextAlign.center,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeText(
            text: content,
            color: theme.appColors.black,
            style: theme.textTheme.h30,
            align: TextAlign.center,
          ),
          hSpace(height: 24),
          DialogPrimaryButton(
            screen: screen,
            text: buttonLabel,
            width: getScreenSize(context).width * 0.6,
            callback: callBack,
          ),
        ],
      ),
    );
  }
}

/// ActionDialogウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(
  name: 'ActionDialog',
  type: ActionDialog,
)
Widget actionDialogUseCase(BuildContext context) {
  final title =
      useStringKnob(context: context, label: 'Title', initialValue: 'タイトル');
  final content =
      useStringKnob(context: context, label: 'Content', initialValue: '説明文');
  final buttonLabel =
      useStringKnob(context: context, label: 'ButtonLabel', initialValue: 'はい');
  void callback() {}

  return ActionDialog(
    title: title,
    screen: 'ActionDialog',
    content: content,
    buttonLabel: buttonLabel,
    callBack: callback,
  );
}
