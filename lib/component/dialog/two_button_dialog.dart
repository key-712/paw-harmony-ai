import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../import/widgetbook.dart';

/// ボタンが二つのダイアログ
class TwoButtonDialog extends ConsumerWidget {
  /// ボタンが二つのダイアログ
  const TwoButtonDialog({
    super.key,
    required this.title,
    required this.screen,
    required this.content,
    required this.primaryText,
    required this.secondaryText,
    required this.primaryCallBack,
    required this.secondaryCallBack,
  });

  /// タイトル
  final String title;

  /// 画面
  final String screen;

  /// 内容
  final String content;

  /// プライマリーテキスト
  final String primaryText;

  /// セカンダリーテキスト
  final String secondaryText;

  /// プライマリーコールバック
  final VoidCallback primaryCallBack;

  /// セカンダリーコールバック
  final VoidCallback secondaryCallBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return AlertDialog(
      backgroundColor: theme.appColors.white,
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
          content.isNotEmpty ? hSpace(height: 24) : Container(),
          Row(
            children: [
              Expanded(
                child: DialogSecondaryButton(
                  text: secondaryText,
                  screen: screen,
                  width: getScreenSize(context).width * 0.4,
                  callback: secondaryCallBack,
                ),
              ),
              wSpace(width: 16),
              Expanded(
                child: DialogPrimaryButton(
                  text: primaryText,
                  screen: screen,
                  width: getScreenSize(context).width * 0.6,
                  callback: primaryCallBack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// TwoButtonDialogウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(
  name: 'TwoButtonDialog',
  type: TwoButtonDialog,
)
Widget twoButtonDialogUseCase(BuildContext context) {
  final title =
      useStringKnob(context: context, label: 'Title', initialValue: 'タイトル');
  final content =
      useStringKnob(context: context, label: 'Content', initialValue: '説明文');
  final primaryText =
      useStringKnob(context: context, label: 'PrimaryText', initialValue: 'はい');
  final secondaryText = useStringKnob(
    context: context,
    label: 'SecondaryText',
    initialValue: 'いいえ',
  );
  void callback() {}

  return TwoButtonDialog(
    title: title,
    screen: 'TwoButtonDialog',
    content: content,
    primaryText: primaryText,
    secondaryText: secondaryText,
    primaryCallBack: callback,
    secondaryCallBack: callback,
  );
}
