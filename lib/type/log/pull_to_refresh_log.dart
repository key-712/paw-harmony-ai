import 'package:freezed_annotation/freezed_annotation.dart';

part 'pull_to_refresh_log.freezed.dart';
part 'pull_to_refresh_log.g.dart';

/// FirebaseAnalyticsのイベントでプルリフレッシュ時のパラメータ設定用のクラス
@freezed
class PullToRefreshLog with _$PullToRefreshLog {
  /// FirebaseAnalyticsのイベントでプルリフレッシュ時のパラメータ設定用のクラス
  factory PullToRefreshLog({
    required String url,
  }) = _PullToRefreshLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory PullToRefreshLog.fromJson(Map<String, dynamic> json) =>
      _$PullToRefreshLogFromJson(json);
}
