import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/theme.dart';

/// 戻るアイコンだけのヘッダー
class OnlyBackIconHeader extends ConsumerWidget implements PreferredSizeWidget {
  /// 戻るアイコンだけのヘッダー
  const OnlyBackIconHeader({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return AppBar(
      iconTheme: IconThemeData(
        color: theme.appColors.black,
      ),
      backgroundColor: theme.appColors.background,
      elevation: 0,
    );
  }
}
