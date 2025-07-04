import 'package:freezed_annotation/freezed_annotation.dart';

part 'tap_button_log.freezed.dart';
part 'tap_button_log.g.dart';

/// FirebaseAnalyticsのイベントでボタンをタップした時のパラメータ設定用のクラス
@freezed
class TapButtonLog with _$TapButtonLog {
  /// インスタンスを作成します
  factory TapButtonLog({
    required String screen,
    required String label,
  }) = _TapButtonLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapButtonLog.fromJson(Map<String, dynamic> json) =>
      _$TapButtonLogFromJson(json);
}
