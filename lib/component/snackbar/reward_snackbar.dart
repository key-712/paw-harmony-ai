import 'package:flutter/material.dart';

import '../../import/component.dart';
import '../../import/theme.dart';

/// 報酬スナックバーを表示します
void showRewardSnackBar({
  required BuildContext context,
  required AppTheme theme,
  required String text,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: theme.appColors.blue,
      content: Row(
        children: [
          Icon(Icons.star, color: theme.appColors.white, size: 20),
          wSpace(width: 8),
          Expanded(
            child: ThemeText(
              text: text,
              color: theme.appColors.white,
              style: theme.textTheme.h30,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
