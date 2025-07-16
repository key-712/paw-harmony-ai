import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback.freezed.dart';
part 'feedback.g.dart';

/// ユーザーフィードバック情報を表すモデルクラス
@freezed
class Feedback with _$Feedback {
  /// フィードバックを作成するファクトリーメソッド
  const factory Feedback({
    required String id,
    required String userId,
    required String dogId,
    required String musicHistoryId,
    required int rating,
    required List<String> behaviorTags,
    String? comment,
    required DateTime createdAt,
  }) = _Feedback;

  /// JSONからFeedbackインスタンスを作成するファクトリーメソッド
  factory Feedback.fromJson(Map<String, dynamic> json) =>
      _$FeedbackFromJson(json);
}
