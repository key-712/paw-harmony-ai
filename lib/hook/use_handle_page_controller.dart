import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';

/// ページコントロールの監視を行います
void useHandlePageController({
  required PageController controller,
  required WidgetRef ref,
}) {
  final walkThroughNotifier =
      ref.watch(walkThroughStateNotifierProvider.notifier);

  useEffect(
    () {
      void listener() {
        final roundedPage = controller.page?.round() ?? 0;
        walkThroughNotifier.updateCurrentPage(roundedPage);
      }

      controller.addListener(listener);
      return () {
        controller.removeListener(listener);
      };
    },
    [],
  );
}
