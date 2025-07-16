import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

import '../../l10n/app_localizations.dart';
import '../import/provider.dart';
import '../import/utility.dart';

/// アップデートをチェックするクラス
class UpdateChecker {
  /// アップデートをチェックするクラス
  UpdateChecker();

  /// アップデートをするか判定する
  Future<void> checkForUpdate({
    required BuildContext context,
    required WidgetRef ref,
    required String screen,
  }) async {
    // 現在のアプリバージョンを取得
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    // バージョンを比較
    if (Version.parse(currentVersion) < Version.parse(minSupportedVersion) &&
        context.mounted) {
      _showUpdateDialog(context: context, ref: ref, screen: screen);
    }
  }

  /// アップデートを促すダイアログを表示
  void _showUpdateDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String screen,
  }) {
    final l10n = AppLocalizations.of(context)!;
    ref
        .watch(dialogStateNotifierProvider.notifier)
        .showActionDialog(
          title: l10n.updateNotice,
          screen: screen,
          content: l10n.updateAvailable,
          buttonLabel: l10n.update,
          barrierDismissible: false,
          forceShow: true,
          context: context,
          callback: () {
            openExternalBrowser(
              url:
                  Platform.isIOS
                      ? ExternalPageList.iosAppLink
                      : ExternalPageList.androidAppLink,
            );
          },
        );
  }
}
