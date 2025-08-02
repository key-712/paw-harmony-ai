import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/theme.dart';

/// 戻るアイコンとタイトルがあるヘッダー
class BackIconHeader extends ConsumerWidget implements PreferredSizeWidget {
  /// 戻るアイコンとタイトルがあるヘッダー
  const BackIconHeader({super.key, required this.title, this.actions});

  /// タイトル
  final String title;

  /// アクション
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return AppBar(
      title: ThemeText(
        text: title,
        color: theme.appColors.black,
        style: theme.textTheme.h40.bold(),
      ),
      leading: BackButton(color: theme.appColors.black),
      backgroundColor: theme.appColors.headerBackground,
      actions: actions,
    );
  }
}
