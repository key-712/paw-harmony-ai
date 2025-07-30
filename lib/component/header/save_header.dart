import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// 保存ボタンがあるヘッダー
class SaveHeader extends ConsumerWidget implements PreferredSizeWidget {
  /// 保存ボタンがあるヘッダー
  const SaveHeader({
    super.key,
    required this.title,
    required this.onSave,
    this.saveEnabled = true,
  });

  /// タイトル
  final String title;

  /// 保存ボタンのアクション
  final VoidCallback onSave;

  /// 保存ボタンの有効/無効状態
  final bool saveEnabled;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: ThemeText(
        text: title,
        color: theme.appColors.black,
        style: theme.textTheme.h40.bold(),
      ),
      backgroundColor: theme.appColors.background,
      actions: [
        SizedBox(
          width: 80,
          child: TextButton(
            onPressed: saveEnabled ? onSave : null,
            child: ThemeText(
              text: l10n.save,
              color: saveEnabled ? theme.appColors.black : theme.appColors.grey,
              style: theme.textTheme.h30,
            ),
          ),
        ),
      ],
    );
  }
}
