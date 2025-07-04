import 'package:freezed_annotation/freezed_annotation.dart';

part 'transit_screen_log.freezed.dart';
part 'transit_screen_log.g.dart';

/// FirebaseAnalyticsのイベントでネイティブの画面遷移した時のパラメータ設定用のクラス
@freezed
class TransitScreenLog with _$TransitScreenLog {
  /// インスタンスを作成します
  factory TransitScreenLog({
    required String from,
    required String to,
  }) = _TransitScreenLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TransitScreenLog.fromJson(Map<String, dynamic> json) =>
      _$TransitScreenLogFromJson(json);
}
