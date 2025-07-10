import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/theme.dart';
import '../../import/utility.dart';

/// ローディング表示Widget
class Loading extends ConsumerWidget {
  /// ローディング表示Widget
  const Loading({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const indicatorSize = 56.0;
    const indicatorStrokeWidth = 6.0;
    final theme = ref.watch(appThemeProvider);
    final screenSize = getScreenSize(ref);

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      color: theme.appColors.black.withValues(alpha: 0.5),
      child: Center(
        child: SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: indicatorStrokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(theme.appColors.progress),
          ),
        ),
      ),
    );
  }
}

/// LoadingウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(name: 'Loading', type: Loading)
Widget loadingUseCase(BuildContext context) {
  return const Loading();
}
