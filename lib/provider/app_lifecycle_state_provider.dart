import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lifecycle_state_provider.g.dart';

/// アプリのライフサイクルの状態を取得します
@Riverpod(keepAlive: true)
class AppLifecycleStateNotifier extends _$AppLifecycleStateNotifier {
  @override
  AppLifecycleState build() {
    final observer = _AppLifecycleObserver((value) {
      state = value;
    });

    final binding = WidgetsBinding.instance..addObserver(observer);
    ref.onDispose(() => binding.removeObserver(observer));

    return AppLifecycleState.resumed;
  }
}

/// アプリのライフサイクルの状態を監視するクラス
class _AppLifecycleObserver extends WidgetsBindingObserver {
  _AppLifecycleObserver(this._didChangeState);

  final ValueChanged<AppLifecycleState> _didChangeState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _didChangeState(state);
    super.didChangeAppLifecycleState(state);
  }
}

/// AppLifecycleStateクラスの拡張関数定義
extension AppLifecycleStateExtension on AppLifecycleState {
  /// アプリのライフサイクルの状態がresumedの場合、true。それ以外は、false。
  bool get isResumed => this == AppLifecycleState.resumed;
}
