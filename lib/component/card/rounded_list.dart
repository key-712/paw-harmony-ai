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
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final actualTextColor = iconColor ?? theme.appColors.main;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (title == l10n.share(l10n.productName)) {
              final appLink =
                  Platform.isIOS
                      ? ExternalPageList.iosAppLink
                      : ExternalPageList.androidAppLink;

              final shareMessage = l10n.shareMessage(appLink, l10n.productName);
              await Share.share(shareMessage);
            } else {
              onTap();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        actualTextColor.withValues(alpha: 0.1),
                        actualTextColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: actualTextColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(icon, color: actualTextColor, size: 22),
                ),
                wSpace(width: 16),
                Expanded(
                  child: ThemeText(
                    text: title,
                    color: theme.appColors.secondary,
                    style: theme.textTheme.h40.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.appColors.main.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: theme.appColors.main,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
