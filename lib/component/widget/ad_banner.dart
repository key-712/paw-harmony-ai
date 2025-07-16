import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../import/utility.dart';

/// 広告バナー
class AdBanner extends HookConsumerWidget {
  /// 広告バナー
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myBanner = AdManagerBannerAd(
      adUnitId:
          Platform.isIOS ? Env.iOSBannerAdUnitId : Env.androidBannerAdUnitId,

      sizes: [AdSize(width: getScreenSize(context).width.toInt(), height: 70)],
      request: const AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          logger.d('Ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => logger.d('Ad opened.'),
        onAdClosed: (Ad ad) {
          ad.dispose();
          logger.d('Ad closed.');
        },
      ),
    )..load();

    final adWidget = AdWidget(ad: myBanner);
    return isNotProduction()
        ? Container(height: 70, color: Colors.transparent)
        : Column(
          children: [
            Container(height: 32, color: Colors.transparent),
            Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              child: SizedBox(
                width: getScreenSize(context).width,
                height: AdSize.fullBanner.height.toDouble(),
                child: adWidget,
              ),
            ),
            Container(height: 32, color: Colors.transparent),
          ],
        );
  }
}
