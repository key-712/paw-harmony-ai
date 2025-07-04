import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_log.freezed.dart';
part 'api_log.g.dart';

/// FirebaseAnalyticsのイベントでAPIのリクエストまたはレスポンス時のパラメータ設定用のクラス
@freezed
class ApiLog with _$ApiLog {
  /// インスタンスを作成します
  factory ApiLog({
    required String uri,
    required String method,
  }) = _ApiLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory ApiLog.fromJson(Map<String, dynamic> json) => _$ApiLogFromJson(json);
}
