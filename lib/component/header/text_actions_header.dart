import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/theme.dart';

/// テキストアクションボタンがあるヘッダー
class TextActionsHeader extends ConsumerWidget implements PreferredSizeWidget {
  /// テキストアクションボタンがあるヘッダー
  const TextActionsHeader({
    super.key,
    required this.title,
    required this.text,
    required this.onPressed,
    this.isLeading = true,
  });

  /// タイトル
  final String title;

  /// アクションボタンのテキスト
  final String text;

  /// アクションボタンのアクション
  final VoidCallback onPressed;

  /// リードボタンを表示するかどうか
  final bool isLeading;

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
      leading: isLeading ? BackButton(color: theme.appColors.black) : null,
      backgroundColor: theme.appColors.headerBackground,
      actions: [
        TextButton(
          onPressed: onPressed,
          child: ThemeText(
            text: text,
            color: theme.appColors.black,
            style: theme.textTheme.h30,
          ),
        ),
      ],
    );
  }
}
