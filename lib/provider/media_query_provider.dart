import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// MediaQuery state notifier for managing screen size efficiently
final mediaQueryStateProvider = StateNotifierProvider<MediaQueryStateNotifier, Size>(
  (ref) => MediaQueryStateNotifier(),
);

/// MediaQuery state notifier class to cache screen size and reduce rebuilds
class MediaQueryStateNotifier extends StateNotifier<Size> {
  /// MediaQuery state notifier class to cache screen size and reduce rebuilds
  MediaQueryStateNotifier() : super(Size.zero);

  /// Update screen size when it changes
  void updateSize(Size size) {
    if (state != size) {
      state = size;
    }
  }
}
