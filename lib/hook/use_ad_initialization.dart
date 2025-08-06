import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/utility.dart';

/// 広告の初期化とロードを行うためのフック
void useAdInitialization({required WidgetRef ref}) {
  final adStateNotifier = ref.watch(adStateNotifierProvider.notifier);

  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.d('広告初期化フックが実行されました');
      // 広告をロードするだけで、すぐには表示しない
      adStateNotifier.loadInterstitialAd();
    });
    return null;
  }, []);
}
