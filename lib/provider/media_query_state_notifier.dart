import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/utility.dart';

/// メディアクエリの変更の通知を管理するプロバイダ
final mediaQueryStateNotifierProvider =
    StateNotifierProvider<MediaQueryStateNotifier, MediaType>(
  (ref) => MediaQueryStateNotifier(),
);

/// メディアクエリの変更を通知するクラス
class MediaQueryStateNotifier extends StateNotifier<MediaType> {
  /// メディアクエリの変更を通知するクラス
  MediaQueryStateNotifier() : super(MediaType.sp);

  /// メディアクエリの更新を行います
  void update({
    required BuildContext context,
  }) {
    final screenWidth = getScreenSize(context).width;
    state =
        screenWidth > WebBreakPoint.breakpointMd ? MediaType.pc : MediaType.sp;
  }
}
