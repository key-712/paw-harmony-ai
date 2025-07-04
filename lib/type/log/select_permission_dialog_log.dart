import 'package:freezed_annotation/freezed_annotation.dart';

part 'select_permission_dialog_log.freezed.dart';
part 'select_permission_dialog_log.g.dart';

/// FirebaseAnalyticsのイベントで許可ダイアログの回答を選択した時のパラメータ設定用のクラス
@freezed
class SelectPermissionDialogLog with _$SelectPermissionDialogLog {
  /// FirebaseAnalyticsのイベントで許可ダイアログの回答を選択した時のパラメータ設定用のクラス
  factory SelectPermissionDialogLog({
    required String isEnable,
  }) = _SelectPermissionDialogLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory SelectPermissionDialogLog.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SelectPermissionDialogLogFromJson(json);
}
