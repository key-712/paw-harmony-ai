import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/root.dart';

/// 画面遷移の処理を行うカスタムフック
void useHandleTransit({
  required BuildContext context,
  required WidgetRef ref,
}) {
  final appNotifier = ref.watch(appStateNotifierProvider.notifier);
  final goRouter = ref.watch(goRouterProvider);

  useEffect(
    () {
      void handleTransit() => appNotifier.handleTransit(context: context);
      goRouter.routerDelegate.addListener(handleTransit);
      return () => goRouter.routerDelegate.removeListener(handleTransit);
    },
    [goRouter],
  );
}
