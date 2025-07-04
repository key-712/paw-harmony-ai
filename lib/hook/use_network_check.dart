import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';

/// ネットワーク接続状態をチェックして、接続がない場合はエラーダイアログを表示します
void useNetworkCheck({
  required BuildContext context,
  required WidgetRef ref,
  required String screen,
}) {
  final networkConnectState = ref.watch(networkConnectStateNotifierProvider);
  final networkConnectStateNotifier =
      ref.watch(networkConnectStateNotifierProvider.notifier);

  useEffect(
    () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await networkConnectStateNotifier.showNetworkError(
          context: context,
          screen: screen,
        );
      });
      return;
    },
    [networkConnectState],
  );
}
