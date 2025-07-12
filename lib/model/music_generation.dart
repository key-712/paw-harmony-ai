import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_generation.freezed.dart';
part 'music_generation.g.dart';

/// 音楽生成リクエスト情報を表すモデルクラス
@freezed
class MusicGenerationRequest with _$MusicGenerationRequest {
  /// 音楽生成リクエストを作成するファクトリーメソッド
  const factory MusicGenerationRequest({
    required String userId,
    required String dogId,
    required String scenario,
    required String dogCondition,
    String? additionalInfo,
    required String dogBreed,
    required List<String> dogPersonalityTraits,
  }) = _MusicGenerationRequest;

  /// JSONからMusicGenerationRequestインスタンスを作成するファクトリーメソッド
  factory MusicGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$MusicGenerationRequestFromJson(json);
}

/// 音楽生成履歴情報を表すモデルクラス
@freezed
class MusicGenerationHistory with _$MusicGenerationHistory {
  /// 音楽生成履歴を作成するファクトリーメソッド
  const factory MusicGenerationHistory({
    required String id,
    required String userId,
    required String dogId,
    required String scenario,
    required String dogCondition,
    required String generatedMusicUrl,
    required int duration,
    required DateTime createdAt,
    required String dogBreed,
    required List<String> dogPersonalityTraits,
  }) = _MusicGenerationHistory;

  /// JSONからMusicGenerationHistoryインスタンスを作成するファクトリーメソッド
  factory MusicGenerationHistory.fromJson(Map<String, dynamic> json) =>
      _$MusicGenerationHistoryFromJson(json);
}
