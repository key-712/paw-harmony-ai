import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';

/// プッシュ通知トークンを取得するためのフック
void usePushNotificationToken({
  required BuildContext context,
  required WidgetRef ref,
}) {
  final pushNotificationStateNotifier =
      ref.watch(pushNotificationStateNotifierProvider.notifier);

  useEffect(
    () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.mounted) {
          await pushNotificationStateNotifier.getToken();
        }
      });
      return null;
    },
    [],
  );
}
