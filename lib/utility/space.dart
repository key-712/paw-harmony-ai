import 'package:flutter/material.dart';

import '../import/utility.dart';

/// タブレット表示かつ画面全体表示時の水平方向のPadding
double tabletHorizontalPadding({required BuildContext context}) {
  return getScreenSize(context).width * 0.08 + 32;
}
