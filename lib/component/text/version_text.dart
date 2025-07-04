import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/theme.dart';

/// アプリバージョンを表示するテキスト
class VersionText extends HookConsumerWidget {
  /// アプリバージョンを表示するテキスト
  const VersionText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final appVersion = useMemoized(PackageInfo.fromPlatform);
    final appVersionFuture = useFuture(appVersion);

    return (appVersionFuture.hasData)
        ? Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ThemeText(
              text: 'version ${appVersionFuture.data!.version}',
              color: theme.appColors.black,
              style: theme.textTheme.h20,
            ),
          )
        : const SizedBox();
  }
}

/// VersionTextウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(
  name: 'VersionText',
  type: VersionText,
)
Widget versionTextUseCase(BuildContext context) {
  return const VersionText();
}
