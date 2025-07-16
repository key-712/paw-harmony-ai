import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/utility.dart';
import 'base_music_service.dart';

/// 音楽生成サービスの種類
enum MusicGenerationServiceType {
  /// Google AI Gemini Pro
  googleAi,

  /// Web Audio API
  webAudio,

  /// Magenta.js
  magenta,
}

/// 音楽生成ファクトリークラス
class MusicGenerationFactory {
  /// MusicGenerationFactoryのコンストラクタ
  MusicGenerationFactory(this.ref);

  /// RiverpodのRefインスタンス
  final Ref ref;

  /// 音楽生成サービスを取得するメソッド
  ///
  /// [serviceType] 使用する音楽生成サービスの種類
  BaseMusicService getMusicService(MusicGenerationServiceType serviceType) {
    switch (serviceType) {
      case MusicGenerationServiceType.googleAi:
        return ref.read(googleAiMusicServiceProvider);
      case MusicGenerationServiceType.webAudio:
        return ref.read(webAudioMusicServiceProvider);
      case MusicGenerationServiceType.magenta:
        return ref.read(magentaMusicServiceProvider);
    }
  }

  /// 利用可能なサービスを確認するメソッド
  Future<List<MusicGenerationServiceType>> getAvailableServices() async {
    final availableServices = <MusicGenerationServiceType>[];

    try {
      // Magenta.jsの確認（常に利用可能）
      availableServices.add(MusicGenerationServiceType.magenta);
      logger.d('Magenta.jsサービスが利用可能です');
    } on Exception catch (e) {
      logger.e('Magenta.jsサービスの確認に失敗', error: e);
    }

    try {
      // Google AIの確認
      final googleService = ref.read(googleAiMusicServiceProvider);
      if (googleService.isApiKeyValid) {
        availableServices.add(MusicGenerationServiceType.googleAi);
        logger.d('Google AIサービスが利用可能です');
      }
    } on Exception catch (e) {
      logger.e('Google AIサービスの確認に失敗', error: e);
    }

    try {
      // Web Audio APIの確認（常に利用可能）
      availableServices.add(MusicGenerationServiceType.webAudio);
      logger.d('Web Audio APIサービスが利用可能です');
    } on Exception catch (e) {
      logger.e('Web Audio APIサービスの確認に失敗', error: e);
    }

    logger.d('利用可能な音楽生成サービス: $availableServices');
    return availableServices;
  }

  /// 最適なサービスを自動選択するメソッド
  Future<MusicGenerationServiceType?> getOptimalService() async {
    final availableServices = await getAvailableServices();

    if (availableServices.isEmpty) {
      logger.w('利用可能な音楽生成サービスがありません');
      return null;
    }

    // 優先順位: Magenta.js > Web Audio API > Google AI
    if (availableServices.contains(MusicGenerationServiceType.magenta)) {
      logger.d('Magenta.jsを選択しました');
      return MusicGenerationServiceType.magenta;
    } else if (availableServices.contains(
      MusicGenerationServiceType.webAudio,
    )) {
      logger.d('Web Audio APIを選択しました');
      return MusicGenerationServiceType.webAudio;
    } else if (availableServices.contains(
      MusicGenerationServiceType.googleAi,
    )) {
      logger.d('Google AIを選択しました');
      return MusicGenerationServiceType.googleAi;
    }

    return null;
  }

  /// 音楽生成を実行するメソッド
  ///
  /// [prompt] 音楽生成のプロンプト
  /// [duration] 音楽の長さ（秒）
  /// [serviceType] 使用するサービス（nullの場合はMagenta.jsをデフォルトで使用）
  /// [config] 生成設定
  Future<Map<String, dynamic>> generateMusic({
    required String prompt,
    int duration = 30,
    MusicGenerationServiceType? serviceType,
    Map<String, dynamic>? config,
  }) async {
    logger.d('=== 音楽生成ファクトリー開始 ===');

    // サービスを選択（デフォルトはMagenta.js）
    final selectedServiceType =
        serviceType ?? MusicGenerationServiceType.magenta;

    final service = getMusicService(selectedServiceType);
    logger.d('選択されたサービス: $selectedServiceType');

    try {
      // サービス固有の設定を適用
      final finalConfig = _getServiceSpecificConfig(
        selectedServiceType,
        config,
      );

      // 音楽生成を実行
      final result = await service.generateMusic(
        prompt: prompt,
        duration: duration,
        config: finalConfig,
      );

      // 結果にサービス情報を追加
      result['service_type'] = selectedServiceType.name;
      result['service_name'] = _getServiceDisplayName(selectedServiceType);

      logger.d('音楽生成完了: ${selectedServiceType.name}');
      return result;
    } on Exception catch (e, st) {
      logger.e(
        '音楽生成エラー: ${selectedServiceType.name}',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// サービス固有の設定を取得するメソッド
  Map<String, dynamic> _getServiceSpecificConfig(
    MusicGenerationServiceType serviceType,
    Map<String, dynamic>? baseConfig,
  ) {
    final config = <String, dynamic>{};

    switch (serviceType) {
      case MusicGenerationServiceType.googleAi:
        config.addAll({
          'temperature': 1.1,
          'top_k': 40,
          'maxOutputTokens': 2048,
        });

      case MusicGenerationServiceType.webAudio:
        config.addAll({
          'bpm': 60,
          'key': 'C',
          'mode': 'major',
          'instruments': ['piano', 'strings'],
          'volume': 0.7,
          'reverb': 0.3,
        });
        {}
      case MusicGenerationServiceType.magenta:
        config.addAll({
          'bpm': 60,
          'key': 'C',
          'mode': 'major',
          'instruments': ['piano', 'strings'],
          'volume': 0.7,
          'temperature': 1.0,
        });
    }

    // ベース設定があればマージ
    if (baseConfig != null) {
      config.addAll(baseConfig);
    }

    return config;
  }

  /// サービスの表示名を取得するメソッド
  String _getServiceDisplayName(MusicGenerationServiceType serviceType) {
    switch (serviceType) {
      case MusicGenerationServiceType.googleAi:
        return 'Google AI Gemini Pro';

      case MusicGenerationServiceType.webAudio:
        return 'Web Audio API';
      case MusicGenerationServiceType.magenta:
        return 'Magenta.js';
    }
  }
}

/// MusicGenerationFactoryを提供するProvider
final musicGenerationFactoryProvider = Provider<MusicGenerationFactory>((ref) {
  return MusicGenerationFactory(ref);
});
