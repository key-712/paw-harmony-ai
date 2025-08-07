import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// 生成回数上限到達お知らせダイアログ
class GenerationLimitNoticeDialog extends ConsumerWidget {
  /// GenerationLimitNoticeDialogのコンストラクタ
  const GenerationLimitNoticeDialog({super.key, required this.context});

  /// ビルドコンテキスト
  final BuildContext context;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);

    return AlertDialog(
      backgroundColor: theme.appColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: SizedBox(
        width: double.infinity,
        child: ThemeText(
          text: l10n.generationLimitReachedTitle,
          color: theme.appColors.black,
          style: theme.textTheme.h50.bold(),
          align: TextAlign.center,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeText(
            text: l10n.generationLimitReachedMessage,
            color: theme.appColors.black,
            style: theme.textTheme.h30,
            align: TextAlign.center,
          ),
          hSpace(height: 24),
          // 閉じるボタン
          DialogPrimaryButton(
            text: l10n.close,
            screen: 'generation_limit_notice_dialog',
            width: double.infinity,
            callback: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

/// 生成回数上限到達お知らせダイアログを表示する関数
Future<void> showGenerationLimitNoticeDialog({
  required BuildContext context,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return GenerationLimitNoticeDialog(context: context);
    },
  );
}
