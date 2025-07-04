// ignore_for_file: lines_longer_than_80_chars
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../import/component.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// 角を丸くしたリスト
class RoundedList extends ConsumerWidget {
  /// 角を丸くしたリスト
  const RoundedList({
    super.key,
    required this.title,
    required this.screen,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  /// リストのタイトル
  final String title;

  /// リストが表示される画面
  final String screen;

  /// リストのアイコン
  final IconData icon;

  /// リストのアイコンの色
  final Color? iconColor;

  /// リストがタップされた時のコールバック
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final actualTextColor = iconColor ?? theme.appColors.grey;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme.appColors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: ListTile(
            title: ThemeText(
              text: title,
              color: theme.appColors.black,
              style: theme.textTheme.h40,
            ),
            leading: Icon(icon, color: actualTextColor),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: theme.appColors.grey.withValues(alpha: 0.7),
              size: 16,
            ),
            onTap: () async {
              if (title == localizations.share(localizations.productName)) {
                final appLink = Platform.isIOS
                    ? ExternalPageList.iosAppLink
                    : ExternalPageList.androidAppLink;

                final shareMessage = localizations.shareMessage(
                  appLink,
                  localizations.productName,
                );
                await Share.share(shareMessage);
              } else {
                onTap();
              }
            },
          ),
        ),
      ],
    );
  }
}
