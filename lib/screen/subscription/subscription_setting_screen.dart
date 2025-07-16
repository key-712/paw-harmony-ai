// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../import/component.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// サブスクリプション設定画面のウィジェット
class SubscriptionSettingScreen extends HookConsumerWidget {
  /// SubscriptionSettingScreenのコンストラクタ
  const SubscriptionSettingScreen({super.key});

  @override
  /// サブスクリプション設定画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // final purchaseState = ref.watch(purchaseStateNotifierProvider);
    final theme = ref.watch(appThemeProvider);
    final offerings = useState<Offerings?>(null);

    // useEffect(() {
    //   /// オファリングを非同期で取得する
    //   Future<void> fetchOfferings() async {
    //     try {
    //       final fetchedOfferings = await Purchases.getOfferings();
    //       offerings.value = fetchedOfferings;
    //     } on PlatformException catch (e) {
    //       // エラーハンドリング: オファリングの取得に失敗した場合
    //       logger.e('Error fetching offerings: $e, details: ${e.details}');
    //       if (context.mounted) {
    //         showAlertSnackBar(
    //           context: context,
    //           theme: theme,
    //           text: l10n.planInformationFetchFailed,
    //         );
    //       }
    //     } on Exception catch (e) {
    //       // その他の予期せぬエラー
    //       logger.e('Unexpected error fetching offerings: $e');
    //       if (context.mounted) {
    //         showAlertSnackBar(
    //           context: context,
    //           theme: theme,
    //           text: l10n.unexpectedError,
    //         );
    //       }
    //     }
    //   }
    //   fetchOfferings();
    //   return null;
    // }, const []);

    return Scaffold(
      appBar: BackIconHeader(title: l10n.subscriptionSettingTitle),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ThemeText(
                text:
                    // purchaseState.isSubscribed
                    // ? l10n.currentPlanPremium
                    // : l10n.currentPlanFree,
                    l10n.currentPlanPremium,
                color: theme.appColors.black,
                style: theme.textTheme.h30.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            hSpace(height: 24),
            ThemeText(
              text: l10n.premiumPlanBenefits,
              color: theme.appColors.black,
              style: theme.textTheme.h30.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            hSpace(height: 8),
            _buildBenefitItem(l10n.unlimitedMusicGeneration, theme),
            _buildBenefitItem(l10n.detailedAnalysisReport, theme),
            _buildBenefitItem(l10n.adFree, theme),
            _buildBenefitItem(l10n.expertCuratedContent, theme),
            hSpace(height: 32),
            if (offerings.value == null)
              const Center(child: CircularProgressIndicator())
            else if (offerings.value!.current == null)
              Center(child: Text(l10n.noAvailablePlans))
            else
              Column(
                children: [
                  ThemeText(
                    text: l10n.selectPlan,
                    color: theme.appColors.black,
                    style: theme.textTheme.h30.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // hSpace(height: 16),
                  // _buildPackageCard(
                  //   context,
                  //   offerings.value!.current!.monthly,
                  //   ref,
                  //   theme,
                  // ),
                  // hSpace(height: 16),
                  // _buildPackageCard(
                  //   context,
                  //   offerings.value!.current!.annual,
                  //   ref,
                  //   theme,
                  // ),
                ],
              ),
            hSpace(height: 32),
            CancelButton(
              text: l10n.continueWithFreePlan,
              screen: 'subscription_screen',
              width: double.infinity,
              isDisabled: false,
              callback: () => const SettingScreenRoute().go(context),
            ),
            hSpace(height: 16),
            ThemeText(
              text: l10n.subscriptionCancellationNote,
              color: theme.appColors.grey,
              style: theme.textTheme.h30.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// メリット項目を構築するプライベートメソッド
  ///
  /// [text] メリットのテキスト
  /// [theme] アプリテーマ
  Widget _buildBenefitItem(String text, AppTheme theme) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green),
        wSpace(width: 8),
        ThemeText(
          text: text,
          color: theme.appColors.black,
          style: theme.textTheme.h30,
        ),
      ],
    ),
  );

  // /// パッケージカードを構築するプライベートメソッド
  // ///
  // /// [context] ビルドコンテキスト
  // /// [package] 課金パッケージ
  // /// [ref] RiverpodのRefインスタンス
  // /// [theme] アプリテーマ
  // Widget _buildPackageCard(
  //   BuildContext context,
  //   Package? package,
  //   WidgetRef ref,
  //   AppTheme theme,
  // ) {
  //   if (package == null) return const SizedBox.shrink();
  //   return Card(
  //     elevation: 2,
  //     child: InkWell(
  //       onTap: () async {
  //         try {
  //           await ref
  //               .read(purchaseStateNotifierProvider.notifier)
  //               .purchaseSubscription();
  //           if (context.mounted) {
  //             showSnackBar(context: context, theme: theme, text: '購入が完了しました！');
  //             const BaseScreenRoute().go(context);
  //           }
  //         } on PlatformException catch (e) {
  //           final errorCode = e.code;
  //           if (errorCode != PurchasesErrorCode.purchaseCancelledError.name) {
  //             if (context.mounted) {
  //               showAlertSnackBar(
  //                 context: context,
  //                 theme: theme,
  //                 text: '購入に失敗しました: ${e.message}',
  //               );
  //             }
  //           }
  //         } on Exception catch (e) {
  //           // その他の予期せぬエラー
  //           logger.e('Unexpected error during purchase: $e');
  //           if (context.mounted) {
  //             showAlertSnackBar(
  //               context: context,
  //               theme: theme,
  //               text: '予期せぬエラーが発生しました。',
  //             );
  //           }
  //         }
  //       },
  //       child: Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             ThemeText(
  //               text: package.storeProduct.title,
  //               color: theme.appColors.black,
  //               style: theme.textTheme.h30.copyWith(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             hSpace(height: 8),
  //             ThemeText(
  //               text: package.storeProduct.description,
  //               color: theme.appColors.grey,
  //               style: theme.textTheme.h30,
  //             ),
  //             hSpace(height: 8),
  //             ThemeText(
  //               text: package.storeProduct.priceString,
  //               color: theme.appColors.black,
  //               style: theme.textTheme.h30.copyWith(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             if (package.storeProduct.introductoryPrice != null)
  //               ThemeText(
  //                 text:
  //                     '初回限定: '
  //                     '${package.storeProduct.introductoryPrice!.priceString} '
  //                     'for '
  //                     '${package.storeProduct.introductoryPrice!.periodNumberOfUnits} '
  //                     '${package.storeProduct.introductoryPrice!.periodUnit.name}',
  //                 color: theme.appColors.green,
  //                 style: theme.textTheme.h30,
  //               ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
