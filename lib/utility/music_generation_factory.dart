import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/utility.dart';
import 'base_music_service.dart';


/// 音楽生成ファクトリークラス
class MusicGenerationFactory {
  /// MusicGenerationFactoryのコンストラクタ
  MusicGenerationFactory(this.ref);

  /// RiverpodのRefインスタンス
  final Ref ref;

  /// 音楽生成サービスを取得するメソッド
  BaseMusicService getMusicService() {
    return ref.read(magentaMusicServiceProvider);
  }


  /// 音楽生成を実行するメソッド
  ///
  /// [prompt] 音楽生成のプロンプト
  /// [duration] 音楽の長さ（秒）
  /// [config] 生成設定
  Future<Map<String, dynamic>> generateMusic({
    required String prompt,
    int duration = 30,
    Map<String, dynamic>? config,
  }) async {
    logger.d('=== 音楽生成ファクトリー開始 ===');

    final service = getMusicService();
    logger.d('選択されたサービス: Magenta.js');

    try {
      // サービス固有の設定を適用
      final finalConfig = _getServiceSpecificConfig(
        config,
      );

      // 音楽生成を実行
      final result = await service.generateMusic(
        prompt: prompt,
        duration: duration,
        config: finalConfig,
      );

      // 結果にサービス情報を追加
      result['service_type'] = 'magenta';
      result['service_name'] = 'Magenta.js';

      logger.d('音楽生成完了: Magenta.js');
      return result;
    } on Exception catch (e, st) {
      logger.e(
        '音楽生成エラー: Magenta.js',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// サービス固有の設定を取得するメソッド
  Map<String, dynamic> _getServiceSpecificConfig(
    Map<String, dynamic>? baseConfig,
  ) {
    final config = <String, dynamic>{
      'bpm': 60,
      'key': 'C',
      'mode': 'major',
      'instruments': ['piano', 'strings'],
      'volume': 0.7,
      'temperature': 1.0,
    };

    // ベース設定があればマージ
    if (baseConfig != null) {
      config.addAll(baseConfig);
    }

    return config;
  }

}

/// MusicGenerationFactoryを提供するProvider
final musicGenerationFactoryProvider =
    Provider((ref) => MusicGenerationFactory(ref));
