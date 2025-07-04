import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';

/// プッシュ通知の設定を更新するためのフック
void usePushNotificationSetting({
  required BuildContext context,
  required WidgetRef ref,
}) {
  final pushNotificationStateNotifier =
      ref.watch(pushNotificationStateNotifierProvider.notifier);

  useEffect(
    () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          pushNotificationStateNotifier.updatePushNotificationSetting(
            context: context,
          );
        }
      });
      return null;
    },
    [],
  );
}
