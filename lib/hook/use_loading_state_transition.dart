import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';

/// ローディング状態を管理するためのフック
void useLoadingStateTransition({
  required WidgetRef ref,
}) {
  final loadingStateNotifier = ref.watch(loadingStateProvider.notifier);

  useEffect(
    () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(
          const Duration(milliseconds: 500),
          loadingStateNotifier.toIdle,
        );
      });
      return null;
    },
    [],
  );
}
