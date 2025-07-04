import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// 設定画面
class SettingScreen extends HookConsumerWidget {
  /// 設定画面
  const SettingScreen({super.key, required this.scrollController});

  /// スクロールコントローラー
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final dialogStateNotifier = ref.watch(dialogStateNotifierProvider.notifier);

    return Scaffold(
      appBar: BaseHeader(title: localizations.setting),
      backgroundColor: theme.appColors.background,
      body: ListView(
        controller: scrollController,
        children: [
          hSpace(height: 16),
          // RoundedList(
          //   title: localizations.premiumFeature,
          //   icon: Icons.diamond,
          //   onTap: () {
          //     ref
          //         .read(purchaseStateNotifierProvider.notifier)
          //         .purchaseSubscription();
          //   },
          // ),
          RoundedList(
            title: localizations.review(localizations.productName),
            screen: ScreenLabel.setting,
            icon: Icons.star,
            iconColor: theme.appColors.yellow,
            onTap: openReview,
          ),
          hSpace(height: 8),
          RoundedList(
            title: localizations.share(localizations.productName),
            screen: ScreenLabel.setting,
            icon: Icons.share,
            iconColor: theme.appColors.green,
            onTap: () {},
          ),
          hSpace(height: 8),
          RoundedList(
            title: localizations.pushNotification,
            screen: ScreenLabel.setting,
            icon: Icons.notifications,
            iconColor: theme.appColors.orange,
            onTap: () {
              const PushScreenRoute().push<void>(context);
            },
          ),
          hSpace(height: 8),
          RoundedList(
            title: localizations.recommendApp,
            screen: ScreenLabel.setting,
            icon: Icons.app_registration,
            iconColor: theme.appColors.purple,
            onTap: () {
              const RecommendAppScreenRoute().push<void>(context);
            },
          ),
          hSpace(height: 8),
          RoundedList(
            title: localizations.contact,
            screen: ScreenLabel.setting,
            icon: Icons.mail,
            iconColor: theme.appColors.blue,
            onTap: () {
              const ContactScreenRoute().push<void>(context);
            },
          ),
          hSpace(height: 8),
          RoundedList(
            title: localizations.frequentlyAskedQuestions,
            screen: ScreenLabel.setting,
            icon: Icons.question_answer,
            iconColor: theme.appColors.red,
            onTap: () {
              dialogStateNotifier.showActionDialog(
                screen: ScreenLabel.setting,
                title: localizations.currentlyCreating,
                content: localizations.currentlyCreatingContent,
                buttonLabel: localizations.close,
                barrierDismissible: false,
                callback: () {},
                context: context,
              );
            },
          ),
          hSpace(height: 8),
          RoundedList(
            title: localizations.languageSetting,
            screen: ScreenLabel.setting,
            icon: Icons.language,
            iconColor: theme.appColors.primary,
            onTap: () {
              const LanguageSettingScreenRoute().push<void>(context);
            },
          ),
          hSpace(height: 8),
          RoundedList(
            title: localizations.legal,
            screen: ScreenLabel.setting,
            icon: Icons.note,
            iconColor: theme.appColors.grey,
            onTap: () {
              openExternalBrowser(url: ExternalPageList.legal);
            },
          ),
          hSpace(height: 8),
          RoundedList(
            title: localizations.privacyPolicy,
            screen: ScreenLabel.setting,
            icon: Icons.note,
            iconColor: theme.appColors.black,
            onTap: () {
              openExternalBrowser(url: ExternalPageList.privacyPolicy);
            },
          ),
          hSpace(height: 8),
          const VersionText(),
        ],
      ),
    );
  }
}
