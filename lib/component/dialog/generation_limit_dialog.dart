import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// 生成回数制限ダイアログ
class GenerationLimitDialog extends ConsumerWidget {
  /// GenerationLimitDialogのコンストラクタ
  const GenerationLimitDialog({super.key, required this.context});

  /// ビルドコンテキスト
  final BuildContext context;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final adNotifier = ref.read(adStateNotifierProvider.notifier);

    return AlertDialog(
      backgroundColor: theme.appColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: SizedBox(
        width: double.infinity,
        child: ThemeText(
          text: l10n.generationLimitTitle,
          color: theme.appColors.black,
          style: theme.textTheme.h50.bold(),
          align: TextAlign.center,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeText(
            text: l10n.watchAd,
            color: theme.appColors.black,
            style: theme.textTheme.h30,
          ),
          hSpace(height: 24),
          // 広告視聴ボタン（主要アクション）
          DialogPrimaryButton(
            text: l10n.watchAdToAddCount,
            screen: 'generation_limit_dialog',
            width: double.infinity,
            callback: () {
              Navigator.of(context).pop();
              adNotifier.showInterstitialAd();
            },
          ),
          // hSpace(height: 12),
          // // サブスクリプションボタン（セカンダリアクション）
          // DialogSecondaryButton(
          //   text: l10n.subscribeToPlan,
          //   screen: 'generation_limit_dialog',
          //   width: double.infinity,
          //   callback: () {
          //     const SubscriptionSettingScreenRoute().push<void>(context);
          //   },
          // ),
          hSpace(height: 12),
          // 閉じるボタン（キャンセルアクション）
          CancelButton(
            text: l10n.close,
            screen: 'generation_limit_dialog',
            width: double.infinity,
            isDisabled: false,
            height: ButtonStyles.dialogButtonHeight,
            callback: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

/// 生成回数制限ダイアログを表示する関数
Future<void> showGenerationLimitDialog({required BuildContext context}) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return GenerationLimitDialog(context: context);
    },
  );
}

@widgetbook.UseCase(name: 'GenerationLimitDialog', type: GenerationLimitDialog)
/// 生成回数制限ダイアログのWidgetbook用メソッド
Widget generationLimitDialogUseCase(BuildContext context) {
  return GenerationLimitDialog(context: context);
}
