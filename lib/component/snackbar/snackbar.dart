import 'package:flutter/material.dart';

import '../../import/component.dart';
import '../../import/theme.dart';

/// スナックバーを表示します
void showSnackBar({
  required BuildContext context,
  required AppTheme theme,
  required String text,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: theme.appColors.green,
      content: ThemeText(
        text: text,
        color: theme.appColors.white,
        style: theme.textTheme.h30,
      ),
    ),
  );
}
