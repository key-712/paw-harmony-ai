import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/theme.dart';

/// 基本的なヘッダー
class BaseHeader extends ConsumerWidget implements PreferredSizeWidget {
  /// 基本的なヘッダー
  const BaseHeader({
    super.key,
    required this.title,
    this.backgroundColor,
  });

  /// タイトル
  final String title;

  /// 背景色
  final Color? backgroundColor;

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
      backgroundColor: backgroundColor ?? theme.appColors.background,
      leading: Container(),
    );
  }
}
