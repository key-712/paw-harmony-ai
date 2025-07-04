import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_api_log.freezed.dart';
part 'request_api_log.g.dart';

/// FirebaseAnalyticsのイベントでAPIのリクエスト時のパラメータ設定用のクラス
@freezed
class RequestApiLog with _$RequestApiLog {
  /// FirebaseAnalyticsのイベントでAPIのリクエスト時のパラメータ設定用のクラス
  factory RequestApiLog({
    required String uri,
    required String method,
  }) = _RequestApiLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory RequestApiLog.fromJson(Map<String, dynamic> json) =>
      _$RequestApiLogFromJson(json);
}
