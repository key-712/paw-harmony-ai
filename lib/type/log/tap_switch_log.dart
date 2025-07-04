import 'package:freezed_annotation/freezed_annotation.dart';

part 'tap_switch_log.freezed.dart';
part 'tap_switch_log.g.dart';

/// FirebaseAnalyticsのイベントでスイッチをタップした時のパラメータ設定用のクラス
@freezed
class TapSwitchLog with _$TapSwitchLog {
  /// インスタンスを作成します
  factory TapSwitchLog({
    required String screen,
    required String label,
    required String isEnabled,
  }) = _TapSwitchLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapSwitchLog.fromJson(Map<String, dynamic> json) =>
      _$TapSwitchLogFromJson(json);
}
