import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/component.dart';
import '../import/model.dart';
import '../import/utility.dart';

/// ダイアログの表示非表示の変更の通知を管理するプロバイダ
final dialogStateNotifierProvider =
    StateNotifierProvider<DialogStateNotifier, bool>(
  (ref) => DialogStateNotifier(),
);

/// ダイアログの表示非表示の変更を通知するクラス
class DialogStateNotifier extends StateNotifier<bool> {
  /// ダイアログの表示非表示の変更を通知するクラス
  DialogStateNotifier() : super(false);

  /// ダイアログを閉じます
  void hideDialog({required BuildContext context}) {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  /// 閉じるボタンのみあるダイアログを表示します
  Future<void> showActionDialog({
    required String title,
    required String screen,
    required String content,
    required String buttonLabel,
    bool barrierDismissible = true,
    bool forceShow = false,
    required VoidCallback callback,
    required BuildContext context,
  }) async {
    if (!forceShow && state) return;
    state = true;
    await showDialog<void>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (context) {
        return ActionDialog(
          screen: screen,
          title: title,
          content: content,
          buttonLabel: buttonLabel,
          callBack: () {
            if (!forceShow) {
              hideDialog(context: context);
            }
            callback();
          },
        );
      },
    );
    state = false;
  }

  /// ボタンが2つあるダイアログを表示します
  Future<void> showTwoButtonDialog({
    required String title,
    required String screen,
    required String content,
    required String primaryText,
    required String secondaryText,
    bool barrierDismissible = true,
    bool forceShow = false,
    required VoidCallback primaryCallBack,
    required VoidCallback secondaryCallBack,
    required BuildContext context,
  }) async {
    if (!forceShow && state) return;
    state = true;
    await showDialog<void>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (context) {
        return TwoButtonDialog(
          screen: screen,
          title: title,
          content: content,
          primaryText: primaryText,
          secondaryText: secondaryText,
          primaryCallBack: () {
            hideDialog(context: context);
            primaryCallBack();
          },
          secondaryCallBack: () {
            hideDialog(context: context);
            secondaryCallBack();
          },
        );
      },
    );
    state = false;
  }

  /// エラー発生時に表示するダイアログを表示します
  void showAppErrorDialog({
    required String screen,
    required AppError error,
    VoidCallback? callback,
    required BuildContext context,
  }) {
    logger.e(error.toString());
    final isBarrierDismissible = error.type != AppErrorType.unauthorized &&
        error.type != AppErrorType.version;
    showActionDialog(
      screen: screen,
      title: error.type.title,
      content: error.message,
      buttonLabel: 'OK',
      barrierDismissible: isBarrierDismissible,
      callback: callback ?? () {},
      context: context,
    );
  }

  /// レビュー依頼ダイアログを表示します
  void showRatingDialog({
    required BuildContext context,
    required String screen,
    required String text,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return RatingDialog(
          screen: screen,
          text: text,
        );
      },
    );
  }

  /// カレンダーダイアログを表示します
  void showCalendarDialog({
    required BuildContext context,
    required TextEditingController dateController,
  }) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CalendarDialog(
          dateController: dateController,
          callBack: () {
            hideDialog(context: context);
          },
        );
      },
    );
  }
}
