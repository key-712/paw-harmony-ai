import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ローディング中かどうかの変更の通知を管理するプロバイダ
final loadingStateProvider = StateNotifierProvider<LoadingStateNotifier, bool>(
  (ref) => LoadingStateNotifier(),
);

/// ローディング中かどうかの変更を通知するクラス
class LoadingStateNotifier extends StateNotifier<bool> {
  /// ローディング中かどうかの変更を通知するクラス
  LoadingStateNotifier() : super(false);

  /// ローディング状態になったことを通知します
  void toLoading() {
    state = true;
  }

  /// ローディング状態ではなくなったことを通知します
  void toIdle() {
    state = false;
  }
}

/// ローディング中かどうかの状態を管理するインスタンスを管理するプロバイダ
final loadingStateManagerProvider = Provider<LoadingStateManager>(
  LoadingStateManager.new,
);

/// ローディング中かどうかの状態を管理するクラス
class LoadingStateManager {
  /// ローディング中かどうかの状態を管理するクラス
  LoadingStateManager(this._ref);

  final Ref _ref;

  /// 非同期型関数実行時のローディング状態の制御
  Future<void> whileLoading({required Future<void> Function() future}) async {
    _ref.read(loadingStateProvider.notifier).toLoading();
    try {
      await future();
    } finally {
      _ref.read(loadingStateProvider.notifier).toIdle();
    }
  }
}
