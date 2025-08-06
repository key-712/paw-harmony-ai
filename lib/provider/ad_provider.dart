import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/type.dart';
import '../import/utility.dart';

/// 広告の状態を管理するProvider
final adStateNotifierProvider = StateNotifierProvider<AdNotifier, AdState>(
  AdNotifier.new,
);

/// 広告の状態を管理するクラス
class AdNotifier extends StateNotifier<AdState> {
  /// 広告の状態を管理するクラス
  AdNotifier(this._ref) : super(AdState(isInterstitialAdLoaded: false));

  // ignore: unused_field
  final Ref _ref;

  /// インタースティシャル広告のインスタンス
  InterstitialAd? interstitialAd;

  /// インタースティシャル広告をロードします
  void loadInterstitialAd() {
    // 開発環境では広告の読み込みをスキップ
    if (isNotProduction()) {
      logger.d('Skipping ad load in development environment');
      return;
    }

    // 実際の広告IDを使用
    final adUnitId =
        Platform.isIOS
            ? Env.iOSInterstitialAdUnitId
            : Env.androidInterstitialAdUnitId;

    // 広告IDが空の場合はスキップ
    if (adUnitId.isEmpty) {
      logger.d('Ad unit ID is empty, skipping ad load');
      return;
    }

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          try {
            interstitialAd = ad;
            state = state.copyWith(isInterstitialAdLoaded: true);

            // 広告がロードされたら自動的に表示を試行
            if (state.shouldShowAdOnLoad) {
              logger.d('Auto-showing ad after load');
              showInterstitialAd();
            }
          } on Exception catch (e) {
            logger.e('Error in onAdLoaded callback: $e');
          }
        },
        onAdFailedToLoad: (error) {
          try {
            state = state.copyWith(
              isInterstitialAdLoaded: false,
              shouldShowAdOnLoad: false,
            );
          } on Exception catch (e) {
            logger.e('Error in onAdFailedToLoad callback: $e');
          }
        },
      ),
    );
  }

  /// インタースティシャル広告を表示します
  void showInterstitialAd() {
    try {
      if (interstitialAd != null) {
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) {},
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            interstitialAd = null;
            // 報酬を付与
            final newRewardCount = state.rewardCount + 1;
            state = state.copyWith(
              isInterstitialAdLoaded: false,
              shouldShowAdOnLoad: false,
              hasReward: true,
              rewardCount: newRewardCount,
            );
            _ref.read(generationCountProvider.notifier).increment();
            loadInterstitialAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            interstitialAd = null;
            state = state.copyWith(
              isInterstitialAdLoaded: false,
              shouldShowAdOnLoad: false,
            );
            loadInterstitialAd();
          },
        );

        logger.d('Calling interstitialAd.show()');
        interstitialAd!.show();
      } else {
        // 広告がロードされたら自動的に表示するようにフラグを設定
        state = state.copyWith(shouldShowAdOnLoad: true);
        loadInterstitialAd();
        // 広告がロードされるまで少し待ってから再試行
        Future.delayed(const Duration(seconds: 2), () {
          if (interstitialAd != null) {
            logger.d('Ad loaded after delay, showing now');
            showInterstitialAd();
          }
        });
      }
    } on Exception catch (e) {
      logger.e('Error in showInterstitialAd: $e');
    }
  }

  /// 広告が利用可能かどうかをチェックする
  bool isAdAvailable() {
    return interstitialAd != null && state.isInterstitialAdLoaded;
  }

  /// 報酬をリセットする
  void resetReward() {
    state = state.copyWith(hasReward: false);
  }

  /// 報酬があるかどうかをチェックする
  bool hasReward() {
    return state.hasReward;
  }

  /// 報酬数を取得する
  int getRewardCount() {
    return state.rewardCount;
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    super.dispose();
  }
}
