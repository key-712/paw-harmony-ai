import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/theme.dart';

/// アクションボタンがあるヘッダー
class IconActionsHeader extends ConsumerWidget implements PreferredSizeWidget {
  /// アクションボタンがあるヘッダー
  const IconActionsHeader({
    super.key,
    required this.title,
    required this.onPressed,
    required this.icon,
  });

  /// タイトル
  final String title;

  /// アクションボタンのアクション
  final VoidCallback onPressed;

  /// アクションボタンのアイコン
  final IconData icon;

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
      backgroundColor: theme.appColors.background,
      actions: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: theme.appColors.black,
          ),
        ),
      ],
    );
  }
}
