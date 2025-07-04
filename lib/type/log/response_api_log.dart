import 'package:freezed_annotation/freezed_annotation.dart';

part 'response_api_log.freezed.dart';
part 'response_api_log.g.dart';

/// FirebaseAnalyticsのイベントでAPIのレスポンス時のパラメータ設定用のクラス
@freezed
class ResponseApiLog with _$ResponseApiLog {
  /// FirebaseAnalyticsのイベントでAPIのレスポンス時のパラメータ設定用のクラス
  factory ResponseApiLog({
    required String uri,
    required String method,
    required String statusCode,
  }) = _ResponseApiLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory ResponseApiLog.fromJson(Map<String, dynamic> json) =>
      _$ResponseApiLogFromJson(json);
}
