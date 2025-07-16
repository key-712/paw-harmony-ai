/// 音楽生成サービスの基底クラス
abstract class BaseMusicService {
  /// APIキーが有効かどうかを確認するメソッド
  bool get isApiKeyValid;

  /// 音楽を生成するメソッド
  ///
  /// [prompt] 音楽生成のプロンプト
  /// [duration] 音楽の長さ（秒）
  /// [config] 生成設定
  Future<Map<String, dynamic>> generateMusic({
    required String prompt,
    int duration = 30,
    Map<String, dynamic>? config,
  });
}
