import 'package:freezed_annotation/freezed_annotation.dart';

part 'tap_card_log.freezed.dart';
part 'tap_card_log.g.dart';

/// FirebaseAnalyticsのイベントでカードをタップした時のパラメータ設定用のクラス
@freezed
class TapCardLog with _$TapCardLog {
  /// インスタンスを作成します
  factory TapCardLog({
    required String screen,
    required String label,
  }) = _TapCardLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapCardLog.fromJson(Map<String, dynamic> json) =>
      _$TapCardLogFromJson(json);
}
