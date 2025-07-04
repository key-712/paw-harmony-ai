import 'package:freezed_annotation/freezed_annotation.dart';

part 'token.freezed.dart';
part 'token.g.dart';

/// 全部のプッシュ通知トークンを取得するWebAPIのレスポンスをトークン個別単位で格納するクラス
@freezed
class Token with _$Token {
  /// 全部のプッシュ通知トークンを取得するWebAPIのレスポンスをトークン個別単位で格納するクラス
  factory Token({
    required String token,
  }) = _Token;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
}
