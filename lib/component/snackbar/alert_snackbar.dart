import 'package:flutter/material.dart';

import '../../import/component.dart';
import '../../import/theme.dart';

/// アラートスナックバーを表示します
void showAlertSnackBar({
  required BuildContext context,
  required AppTheme theme,
  required String text,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: theme.appColors.red,
      content: ThemeText(
        text: text,
        color: theme.appColors.white,
        style: theme.textTheme.h30,
      ),
    ),
  );
}
