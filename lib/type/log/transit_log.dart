import 'package:freezed_annotation/freezed_annotation.dart';

part 'transit_log.freezed.dart';
part 'transit_log.g.dart';

/// FirebaseAnalyticsのイベントで遷移した時のパラメータ設定用のクラス
@freezed
class TransitLog with _$TransitLog {
  /// インスタンスを作成します
  factory TransitLog({
    required String from,
    required String to,
  }) = _TransitLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TransitLog.fromJson(Map<String, dynamic> json) =>
      _$TransitLogFromJson(json);
}
