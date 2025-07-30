// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
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
    final purchaseState = ref.watch(purchaseStateNotifierProvider);
    final theme = ref.watch(appThemeProvider);
    final offerings = useState<Offerings?>(null);

    useEffect(() {
      /// オファリングを非同期で取得する
      Future<void> fetchOfferings() async {
        try {
          // APIキーが設定されているかチェック
          const appleApiKey = Env.revenueCatAppleApiKey;
          const googleApiKey = Env.revenueCatGoogleApiKey;

          if (appleApiKey.isEmpty && googleApiKey.isEmpty) {
            logger.w('RevenueCat API keys are not configured');
            if (context.mounted) {
              showAlertSnackBar(
                context: context,
                theme: theme,
                text: 'RevenueCatの設定が完了していません。開発者にお問い合わせください。',
              );
            }
            return;
          }

          // RevenueCatが初期化されているかチェック
          try {
            logger
              ..i('Attempting to fetch offerings from RevenueCat...')
              ..i('Platform: ${Platform.operatingSystem}')
              ..i('Flavor: ${Env.flavor}');
            final fetchedOfferings = await Purchases.getOfferings();
            offerings.value = fetchedOfferings;
            logger.i(
              'Offerings fetched successfully: ${fetchedOfferings.current != null ? 'Available' : 'Not available'}',
            );

            // 詳細なデバッグ情報を追加
            if (fetchedOfferings.current != null) {
              logger
                ..i('Current offering: ${fetchedOfferings.current!.identifier}')
                ..i(
                  'Available packages: ${fetchedOfferings.current!.availablePackages.length}',
                );
              for (final package
                  in fetchedOfferings.current!.availablePackages) {
                logger.i(
                  'Package: ${package.identifier} - ${package.storeProduct.title}',
                );
              }
            } else {
              logger
                ..w('No current offering available')
                ..i('All offerings: ${fetchedOfferings.all.keys.join(', ')}');
            }
          } on PlatformException catch (e) {
            // RevenueCatが初期化されていない場合
            if (e.code == '23' || e.code == 'CONFIGURATION_ERROR') {
              const flavor = Env.flavor;
              logger
                ..i('RevenueCat configuration error detected')
                ..i('Error code: ${e.code}')
                ..i('Error message: ${e.message}')
                ..i(
                  'More information: https://rev.cat/why-are-offerings-empty',
                );

              if (flavor == 'dev') {
                logger.w(
                  'RevenueCat is not properly initialized. This is expected in development.',
                );
              } else {
                logger.w(
                  'RevenueCat products not configured in dashboard. This is expected until products are set up.',
                );
              }
              return;
            }
            rethrow;
          }
        } on PlatformException catch (e) {
          // 開発環境では設定エラーを無視し、静かに処理する
          if (e.code == '23' || e.code == 'CONFIGURATION_ERROR') {
            logger.w(
              'RevenueCat configuration error in development environment. This is expected during development.',
            );
            return;
          }

          // エラーハンドリング: オファリングの取得に失敗した場合
          logger.e('Error fetching offerings: $e, details: ${e.details}');

          if (context.mounted) {
            var errorMessage = l10n.planInformationFetchFailed;
            // より具体的なエラーメッセージを提供
            if (e.code == '11' || e.code == 'INVALID_CREDENTIALS') {
              errorMessage = 'RevenueCatのAPIキーが無効です。設定を確認してください。';
            } else if (e.code == 'NETWORK_ERROR') {
              errorMessage = 'ネットワークエラーが発生しました。接続を確認してください。';
            }
            showAlertSnackBar(
              context: context,
              theme: theme,
              text: errorMessage,
            );
          }
        } on Exception catch (e) {
          // その他の予期せぬエラー
          logger.e('Unexpected error fetching offerings: $e');
          if (context.mounted) {
            showAlertSnackBar(
              context: context,
              theme: theme,
              text: l10n.unexpectedError,
            );
          }
        }
      }

      fetchOfferings();
      return null;
    }, const []);

    return Scaffold(
      appBar: BackIconHeader(title: l10n.subscriptionSettingTitle),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ThemeText(
                  text:
                      purchaseState.isSubscribed
                          ? l10n.currentPlanPremium
                          : l10n.currentPlanFree,
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
              _buildBenefitItem(
                text: l10n.unlimitedMusicGeneration,
                theme: theme,
              ),
              _buildBenefitItem(
                text: l10n.detailedAnalysisReport,
                theme: theme,
              ),
              _buildBenefitItem(text: l10n.adFree, theme: theme),
              _buildBenefitItem(text: l10n.expertCuratedContent, theme: theme),
              hSpace(height: 32),
              if (offerings.value == null)
                const Center(child: Loading())
              else if (offerings.value!.current == null ||
                  offerings.value!.current!.monthly == null ||
                  offerings.value!.current!.annual == null)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.appColors.grey,
                        size: 48,
                      ),
                      hSpace(height: 16),
                      ThemeText(
                        text: '現在、プランの情報を取得できません。\nしばらく時間をおいてから再度お試しください。',
                        color: theme.appColors.grey,
                        style: theme.textTheme.h30.copyWith(fontSize: 14),
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                )
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
                    hSpace(height: 16),
                    _buildPackageCard(
                      context: context,
                      package: offerings.value!.current!.monthly,
                      ref: ref,
                      theme: theme,
                      l10n: l10n,
                    ),
                    hSpace(height: 16),
                    _buildPackageCard(
                      context: context,
                      package: offerings.value!.current!.annual,
                      ref: ref,
                      theme: theme,
                      l10n: l10n,
                    ),
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
      ),
    );
  }

  /// メリット項目を構築するプライベートメソッド
  ///
  /// [text] メリットのテキスト
  /// [theme] アプリテーマ
  Widget _buildBenefitItem({required String text, required AppTheme theme}) =>
      Padding(
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

  /// パッケージカードを構築するプライベートメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [package] 課金パッケージ
  /// [ref] RiverpodのRefインスタンス
  /// [theme] アプリテーマ
  /// [l10n] ローカライゼーション
  Widget _buildPackageCard({
    required BuildContext context,
    required Package? package,
    required WidgetRef ref,
    required AppTheme theme,
    required AppLocalizations l10n,
  }) {
    if (package == null) return const SizedBox.shrink();
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () async {
          try {
            await ref
                .read(purchaseStateNotifierProvider.notifier)
                .purchaseSubscription();
            if (context.mounted) {
              showSnackBar(
                context: context,
                theme: theme,
                text: l10n.purchaseCompleted,
              );
              const BaseScreenRoute().go(context);
            }
          } on PlatformException catch (e) {
            final errorCode = e.code;
            if (errorCode != PurchasesErrorCode.purchaseCancelledError.name) {
              if (context.mounted) {
                showAlertSnackBar(
                  context: context,
                  theme: theme,
                  text: '購入に失敗しました: ${e.message}',
                );
              }
            }
          } on Exception catch (e) {
            // その他の予期せぬエラー
            logger.e('Unexpected error during purchase: $e');
            if (context.mounted) {
              showAlertSnackBar(
                context: context,
                theme: theme,
                text: l10n.unexpectedError,
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThemeText(
                text: package.storeProduct.title,
                color: theme.appColors.black,
                style: theme.textTheme.h30.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              hSpace(height: 8),
              ThemeText(
                text: package.storeProduct.description,
                color: theme.appColors.grey,
                style: theme.textTheme.h30,
              ),
              hSpace(height: 8),
              ThemeText(
                text: package.storeProduct.priceString,
                color: theme.appColors.black,
                style: theme.textTheme.h30.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (package.storeProduct.introductoryPrice != null)
                ThemeText(
                  text:
                      '初回限定: '
                      '${package.storeProduct.introductoryPrice!.priceString} '
                      'for '
                      '${package.storeProduct.introductoryPrice!.periodNumberOfUnits} '
                      '${package.storeProduct.introductoryPrice!.periodUnit.name}',
                  color: theme.appColors.green,
                  style: theme.textTheme.h30,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
