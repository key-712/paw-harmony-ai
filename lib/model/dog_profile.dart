import 'package:freezed_annotation/freezed_annotation.dart';

part 'dog_profile.freezed.dart';
part 'dog_profile.g.dart';

/// 犬のプロフィール情報を表すモデルクラス
@freezed
class DogProfile with _$DogProfile {
  /// 犬のプロフィールを作成するファクトリーメソッド
  const factory DogProfile({
    required String id,
    required String userId,
    required String name,
    required String breed,
    DateTime? dateOfBirth,
    int? age,
    required String gender,
    required List<String> personalityTraits,
    String? profileImageUrl,
  }) = _DogProfile;

  /// JSONからDogProfileインスタンスを作成するファクトリーメソッド
  factory DogProfile.fromJson(Map<String, dynamic> json) =>
      _$DogProfileFromJson(json);
}
