import 'package:freezed_annotation/freezed_annotation.dart';

part 'tap_quick_action_log.freezed.dart';
part 'tap_quick_action_log.g.dart';

/// FirebaseAnalyticsのイベントでクイックアクションをタップした時のパラメータ設定用のクラス
@freezed
class TapQuickActionLog with _$TapQuickActionLog {
  /// インスタンスを作成します
  factory TapQuickActionLog({
    required String path,
  }) = _TapQuickActionLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapQuickActionLog.fromJson(Map<String, dynamic> json) =>
      _$TapQuickActionLogFromJson(json);
}
