import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/type.dart';
import '../import/utility.dart';

/// 広告の状態を管理するProvider
final AutoDisposeStateNotifierProvider<AdNotifier, AdState>
adStateNotifierProvider =
    StateNotifierProvider.autoDispose<AdNotifier, AdState>(AdNotifier.new);

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
          interstitialAd = ad;
          logger.d('InterstitialAd loaded: $ad');
          _ref.read(generationCountProvider.notifier).increment();
          state = state.copyWith(isInterstitialAdLoaded: true);
        },
        onAdFailedToLoad: (error) {
          logger.d('InterstitialAd failed to load: $error');
          state = state.copyWith(isInterstitialAdLoaded: false);
        },
      ),
    );
  }

  /// インタースティシャル広告を表示します
  void showInterstitialAd() {
    if (isNotProduction()) return;

    if (interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          interstitialAd = null;
          state = state.copyWith(isInterstitialAdLoaded: false);
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          interstitialAd = null;
          state = state.copyWith(isInterstitialAdLoaded: false);
          loadInterstitialAd();
        },
      );
      interstitialAd!.show();
    }
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    super.dispose();
  }
}
