import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';

/// 表示画面のサイズを取得します (optimized version using provider)
Size getScreenSize(WidgetRef ref) => ref.watch(mediaQueryStateProvider);

/// 表示画面のサイズを取得します (legacy version for backward compatibility)
Size getScreenSizeFromContext(BuildContext context) => MediaQuery.of(context).size;
