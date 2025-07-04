import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ボタンが二つのダイアログの表示非表示の変更の通知を管理するプロバイダ
final twoButtonDialogStateProvider =
    StateNotifierProvider<TwoButtonDialogStateNotifier, bool>(
  (ref) => TwoButtonDialogStateNotifier(),
);

/// ボタンが二つのダイアログの表示非表示の変更を通知するクラス
class TwoButtonDialogStateNotifier extends StateNotifier<bool> {
  /// ボタンが二つのダイアログの表示非表示の変更を通知するクラス
  TwoButtonDialogStateNotifier() : super(false);

  /// ダイアログが表示状態になったことを通知します
  void showDialog() {
    state = true;
  }

  /// ダイアログが非表示状態になったことを通知します
  void hideDialog() {
    state = false;
  }
}
