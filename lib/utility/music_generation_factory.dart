import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/utility.dart';

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
    logger.d('音楽生成開始');

    final service = getMusicService();

    try {
      // サービス固有の設定を適用
      final finalConfig = _getServiceSpecificConfig(config);

      // 音楽生成を実行
      final result = await service.generateMusic(
        prompt: prompt,
        duration: duration,
        config: finalConfig,
      );
      result['service_type'] = 'magenta';
      result['service_name'] = 'Magenta.js';
      return result;
    } on Exception catch (e, st) {
      logger.e('音楽生成エラー', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// サービス固有の設定を取得するメソッド
  Map<String, dynamic> _getServiceSpecificConfig(
    Map<String, dynamic>? baseConfig,
  ) {
    // 基本設定
    final config = <String, dynamic>{
      'bpm': 60,
      'key': 'C',
      'mode': 'major',
      'volume': 0.7,
      'temperature': 1.0,
    };

    // ベース設定があればマージ
    if (baseConfig != null) {
      config.addAll(baseConfig);
    }

    // プロンプトから楽器設定を動的に決定
    final instruments = _determineInstrumentsFromConfig(config);
    config['instruments'] = instruments;

    return config;
  }

  /// 設定から楽器を動的に決定するメソッド
  List<String> _determineInstrumentsFromConfig(Map<String, dynamic> config) {
    // デフォルトの楽器セット（レゲエ、ソフトロック、クラシックを重視）
    final defaultInstruments = ['piano', 'strings', 'acoustic_guitar'];

    // 設定から楽器を推測
    final instruments = <String>[];

    // シーンや条件に基づいて楽器を選択（レゲエ、ソフトロック、クラシックを重視）
    if (config.containsKey('scenario')) {
      final scenario = config['scenario'] as String?;
      final scenarioKey = _getScenarioKey(scenario ?? '');
      switch (scenarioKey) {
        case 'sceneLeavingHome':
          // レゲエ風：ベース、ギター、パーカッション
          instruments.addAll([
            'bass',
            'acoustic_guitar',
            'percussion',
            'strings',
          ]);
        case 'sceneBedtime':
          // クラシック風：弦楽器、ピアノ、ハープ
          instruments.addAll(['strings', 'piano', 'harp', 'cello']);
        case 'sceneStressful':
          // ソフトロック風：アコースティックギター、ピアノ、弦楽器
          instruments.addAll(['acoustic_guitar', 'piano', 'strings', 'bass']);
        case 'sceneLongDistanceTravel':
          // レゲエ風：ベース、ギター、パーカッション
          instruments.addAll([
            'bass',
            'acoustic_guitar',
            'percussion',
            'strings',
          ]);
        case 'sceneDailyHealing':
          // クラシック風：弦楽四重奏
          instruments.addAll(['violin', 'viola', 'cello', 'piano']);
        case 'sceneCare':
          // ソフトロック風：癒し系アコースティック
          instruments.addAll(['acoustic_guitar', 'piano', 'strings', 'bass']);
        case 'sceneThunderFireworks':
          // クラシック風：深いベースで音をマスク
          instruments.addAll(['bass', 'cello', 'strings', 'piano']);
        case 'sceneSeparationAnxiety':
          // ソフトロック風：安心感を与える楽器
          instruments.addAll(['acoustic_guitar', 'piano', 'strings', 'bass']);
        case 'sceneNewEnvironment':
          // レゲエ風：安定感を与える楽器
          instruments.addAll([
            'bass',
            'acoustic_guitar',
            'percussion',
            'strings',
          ]);
        case 'scenePostExercise':
          // クラシック風：心拍数を下げる楽器
          instruments.addAll(['piano', 'strings', 'harp', 'cello']);
        case 'sceneGrooming':
          // ソフトロック風：リラックスした楽器
          instruments.addAll(['acoustic_guitar', 'piano', 'strings']);
        case 'sceneMealTime':
          // クラシック風：食事を楽しむ楽器
          instruments.addAll(['strings', 'piano', 'woodwinds']);
        case 'scenePlayTime':
          // レゲエ風：楽しい楽器
          instruments.addAll([
            'bass',
            'acoustic_guitar',
            'percussion',
            'piano',
          ]);
        case 'sceneTraining':
          // ソフトロック風：集中力を高める楽器
          instruments.addAll(['acoustic_guitar', 'piano', 'strings', 'bass']);
        case 'sceneGuests':
          // クラシック風：歓迎の楽器
          instruments.addAll(['strings', 'piano', 'woodwinds']);
        case 'sceneBadWeather':
          // ソフトロック風：慰めの楽器
          instruments.addAll(['acoustic_guitar', 'piano', 'strings']);
        case 'sceneSeasonalChange':
          // クラシック風：季節に適応する楽器
          instruments.addAll(['strings', 'piano', 'woodwinds']);
        case 'scenePuppySocialization':
          // レゲエ風：好奇心を刺激する楽器
          instruments.addAll([
            'bass',
            'acoustic_guitar',
            'percussion',
            'piano',
          ]);
        case 'sceneSeniorCare':
          // ソフトロック風：シニア犬に優しい楽器
          instruments.addAll(['acoustic_guitar', 'piano', 'strings', 'bass']);
        case 'sceneMultipleDogs':
          // クラシック風：調和を促進する楽器
          instruments.addAll(['strings', 'piano', 'woodwinds']);
        case 'sceneVetVisit':
          // ソフトロック風：不安を軽減する楽器
          instruments.addAll(['acoustic_guitar', 'piano', 'strings']);
        default:
          instruments.addAll(defaultInstruments);
      }
    } else {
      // 設定から楽器を推測（レゲエ、ソフトロック、クラシックの要素を反映）
      final brightness = config['brightness'] as double? ?? 0.5;
      final density = config['density'] as double? ?? 0.5;
      final bpm = config['bpm'] as int? ?? 60;
      final reverb = config['reverb'] as double? ?? 0.3;

      // 明度に基づく楽器選択
      if (brightness < 0.4) {
        // 暗い音色：レゲエのベース、クラシックのチェロ
        instruments.addAll(['bass', 'cello', 'piano']);
      } else if (brightness > 0.6) {
        // 明るい音色：ソフトロックのギター、クラシックの弦楽器
        instruments.addAll(['acoustic_guitar', 'violin', 'piano']);
      } else {
        // 中間的な音色：バランスの取れた組み合わせ
        instruments.addAll(['piano', 'strings', 'acoustic_guitar', 'bass']);
      }

      // 密度に基づく楽器選択
      if (density < 0.3) {
        // 密度が低い：シンプルな楽器
        instruments.addAll(['piano', 'acoustic_guitar']);
      } else if (density > 0.7) {
        // 密度が高い：豊かな楽器
        instruments.addAll(['strings', 'bass', 'percussion', 'piano']);
      }

      // テンポに基づく楽器選択
      if (bpm < 70) {
        // 遅いテンポ：クラシック風
        instruments.addAll(['cello', 'piano', 'strings']);
      } else if (bpm > 100) {
        // 速いテンポ：レゲエ風
        instruments.addAll(['bass', 'acoustic_guitar', 'percussion']);
      } else {
        // 中間テンポ：ソフトロック風
        instruments.addAll(['acoustic_guitar', 'piano', 'strings']);
      }

      // リバーブに基づく楽器選択
      if (reverb > 0.5) {
        // リバーブが多い：クラシック風
        instruments.addAll(['strings', 'piano', 'harp']);
      } else if (reverb < 0.2) {
        // リバーブが少ない：レゲエ風
        instruments.addAll(['bass', 'acoustic_guitar', 'percussion']);
      }
    }

    // 犬種に基づく楽器調整
    if (config.containsKey('breed')) {
      final breed = config['breed'] as String?;
      if (breed != null) {
        final breedKey = _getBreedKey(breed);
        switch (breedKey) {
          case 'breedChihuahua':
          case 'breedToyPoodle':
            // 小型犬：クラシックの優しい楽器
            instruments.addAll(['piano', 'harp', 'violin']);
          case 'breedGoldenRetriever':
          case 'breedLabrador':
            // 大型犬：レゲエの温かい楽器
            instruments.addAll(['bass', 'acoustic_guitar', 'strings']);
          case 'breedShibaInu':
          case 'breedAkita':
            // 日本犬：クラシックの平和な楽器
            instruments.addAll(['strings', 'piano', 'cello']);
          default:
            // その他の犬種：汎用的な楽器
            break;
        }
      }
    }

    // 重複を除去してユニークな楽器リストを作成
    final uniqueInstruments = instruments.toSet().toList();

    // 最低1つの楽器は確保
    if (uniqueInstruments.isEmpty) {
      uniqueInstruments.addAll(defaultInstruments);
    }

    return uniqueInstruments;
  }

  /// シーン文字列から多言語キーを取得するヘルパーメソッド
  String _getScenarioKey(String scenario) {
    switch (scenario) {
      case '留守番中':
        return 'sceneLeavingHome';
      case '就寝前':
        return 'sceneBedtime';
      case 'ストレスフル':
        return 'sceneStressful';
      case '長距離移動中':
        return 'sceneLongDistanceTravel';
      case '日常の癒し':
        return 'sceneDailyHealing';
      case '療養/高齢犬ケア':
        return 'sceneCare';
      case '雷・花火の恐怖':
        return 'sceneThunderFireworks';
      case '分離不安':
        return 'sceneSeparationAnxiety';
      case '新しい環境への適応':
        return 'sceneNewEnvironment';
      case '運動後のクールダウン':
        return 'scenePostExercise';
      case 'グルーミング時':
        return 'sceneGrooming';
      case '食事時':
        return 'sceneMealTime';
      case '遊び時間':
        return 'scenePlayTime';
      case 'トレーニング時':
        return 'sceneTraining';
      case '来客時':
        return 'sceneGuests';
      case '天候不良時':
        return 'sceneBadWeather';
      case '季節の変わり目':
        return 'sceneSeasonalChange';
      case '子犬の社会化':
        return 'scenePuppySocialization';
      case 'シニア犬のケア':
        return 'sceneSeniorCare';
      case '多頭飼いの調和':
        return 'sceneMultipleDogs';
      case '獣医訪問前':
        return 'sceneVetVisit';
      default:
        return 'sceneLeavingHome';
    }
  }

  /// 犬種文字列から多言語キーを取得するヘルパーメソッド
  String _getBreedKey(String breed) {
    switch (breed.toLowerCase()) {
      // 小型犬
      case 'チワワ':
      case 'chihuahua':
        return 'breedChihuahua';
      case 'トイプードル':
      case 'toy poodle':
      case 'toypoodle':
        return 'breedToyPoodle';

      // 大型犬
      case 'ゴールデンレトリーバー':
      case 'golden retriever':
      case 'goldenretriever':
        return 'breedGoldenRetriever';
      case 'ラブラドールレトリーバー':
      case 'labrador retriever':
      case 'labrador':
        return 'breedLabrador';

      // 日本犬
      case '柴犬':
      case 'shiba inu':
      case 'shibainu':
        return 'breedShibaInu';
      case '秋田犬':
      case 'akita inu':
      case 'akita':
        return 'breedAkita';

      default:
        return 'breedGeneric'; // デフォルト値
    }
  }
}

/// MusicGenerationFactoryを提供するProvider
final Provider<MusicGenerationFactory> musicGenerationFactoryProvider =
    Provider(MusicGenerationFactory.new);
