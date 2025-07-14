// ignore_for_file: lines_longer_than_80_chars

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
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final dogProfile = ref.watch(dogProfileStateNotifierProvider);
    final purchaseState = ref.watch(purchaseStateNotifierProvider);

    return Scaffold(
      appBar: BaseHeader(title: l10n.setting),
      backgroundColor: theme.appColors.background,
      body: dogProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: ThemeText(
                text: l10n.errorOccurred(err.toString()),
                color: theme.appColors.black,
                style: theme.textTheme.h30,
              ),
            ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: ThemeText(
                text: l10n.noProfile,
                color: theme.appColors.black,
                style: theme.textTheme.h30,
              ),
            );
          }

          return ListView(
            controller: scrollController,
            children: [
              hSpace(height: 16),
              // プロフィール情報
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        profile.profileImageUrl != null
                            ? NetworkImage(profile.profileImageUrl!)
                            : null,
                    child:
                        profile.profileImageUrl == null
                            ? const Icon(Icons.pets)
                            : null,
                  ),
                  title: ThemeText(
                    text: profile.name,
                    color: theme.appColors.black,
                    style: theme.textTheme.h30.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: ThemeText(
                    text: l10n.dogAge(profile.breed, profile.age ?? 0),
                    color: theme.appColors.grey,
                    style: theme.textTheme.h30,
                  ),
                  onTap:
                      () => const DogProfileScreenRoute().push<void>(context),
                ),
              ),
              hSpace(height: 16),

              // サブスクリプション情報
              Card(
                child: ListTile(
                  leading: const Icon(Icons.star),
                  title: ThemeText(
                    text: l10n.currentPlan,
                    color: theme.appColors.black,
                    style: theme.textTheme.h30,
                  ),
                  subtitle: ThemeText(
                    text: purchaseState.isSubscribed
                        ? l10n.premiumPlan
                        : l10n.freePlan,
                    color: theme.appColors.grey,
                    style: theme.textTheme.h30,
                  ),
                  trailing:
                      purchaseState.isSubscribed
                          ? null
                          : SecondaryButton(
                            text: l10n.upgrade,
                            screen: 'subscription_screen',
                            width: 180,
                            isDisabled: false,
                            callback:
                                () => const SubscriptionSettingScreenRoute()
                                    .push<void>(context),
                          ),
                ),
              ),
              hSpace(height: 16),
              // 設定メニュー
              Card(
                child: Column(
                  children: [
                    RoundedList(
                      title: l10n.review(l10n.productName),
                      screen: ScreenLabel.setting,
                      icon: Icons.star,
                      iconColor: theme.appColors.yellow,
                      onTap: openReview,
                    ),
                    hSpace(height: 8),
                    RoundedList(
                      title: l10n.share(l10n.productName),
                      screen: ScreenLabel.setting,
                      icon: Icons.share,
                      iconColor: theme.appColors.green,
                      onTap: () {},
                    ),
                    hSpace(height: 8),
                    RoundedList(
                      title: l10n.pushNotification,
                      screen: ScreenLabel.setting,
                      icon: Icons.notifications,
                      iconColor: theme.appColors.orange,
                      onTap: () {
                        const PushScreenRoute().push<void>(context);
                      },
                    ),
                    hSpace(height: 8),
                    RoundedList(
                      title: l10n.recommendApp,
                      screen: ScreenLabel.setting,
                      icon: Icons.app_registration,
                      iconColor: theme.appColors.purple,
                      onTap: () {
                        const RecommendAppScreenRoute().push<void>(context);
                      },
                    ),
                    hSpace(height: 8),
                    RoundedList(
                      title: l10n.contact,
                      screen: ScreenLabel.setting,
                      icon: Icons.mail,
                      iconColor: theme.appColors.blue,
                      onTap: () {
                        const ContactScreenRoute().push<void>(context);
                      },
                    ),
                    hSpace(height: 8),
                    RoundedList(
                      title: l10n.languageSetting,
                      screen: ScreenLabel.setting,
                      icon: Icons.language,
                      iconColor: theme.appColors.primary,
                      onTap: () {
                        const LanguageSettingScreenRoute().push<void>(context);
                      },
                    ),
                    hSpace(height: 8),
                    RoundedList(
                      title: l10n.legal,
                      screen: ScreenLabel.setting,
                      icon: Icons.note,
                      iconColor: theme.appColors.grey,
                      onTap: () {
                        openExternalBrowser(url: ExternalPageList.legal);
                      },
                    ),
                    hSpace(height: 8),
                    RoundedList(
                      title: l10n.privacyPolicy,
                      screen: ScreenLabel.setting,
                      icon: Icons.note,
                      iconColor: theme.appColors.black,
                      onTap: () {
                        openExternalBrowser(
                          url: ExternalPageList.privacyPolicy,
                        );
                      },
                    ),
                    hSpace(height: 8),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: ThemeText(
                        text: l10n.logout,
                        color: theme.appColors.red,
                        style: theme.textTheme.h30,
                      ),
                      onTap: () {
                        ref.read(authStateNotifierProvider.notifier).signOut();
                        const LoginScreenRoute().go(context);
                      },
                    ),
                  ],
                ),
              ),
              hSpace(height: 16),
              const VersionText(),
            ],
          );
        },
      ),
    );
  }
}
