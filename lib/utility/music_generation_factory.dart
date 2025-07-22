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

    // シーンや条件に基づいて楽器を選択（IDベースで分岐）
    if (config.containsKey('scenario')) {
      final scenarioId = config['scenario'] as String?;
      switch (scenarioId) {
        case '1':
        case '4':
        case '9':
        case '13':
        case '18':
          // レゲエ風：ベース、ギター、パーカッション
          instruments.addAll([
            'bass',
            'acoustic_guitar',
            'percussion',
            'strings',
          ]);
        case '2':
        case '5':
        case '10':
        case '12':
        case '15':
        case '17':
        case '20':
          // クラシック風
          instruments.addAll([
            'strings',
            'piano',
            'harp',
            'cello',
            'woodwinds',
            'violin',
            'viola',
          ]);
        case '3':
        case '6':
        case '8':
        case '11':
        case '14':
        case '16':
        case '19':
        case '21':
          // ソフトロック風
          instruments.addAll(['acoustic_guitar', 'piano', 'strings', 'bass']);
        case '7':
          // クラシック風：深いベースで音をマスク
          instruments.addAll(['bass', 'cello', 'strings', 'piano']);
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
        final breedKey = getBreedKey(breed);
        switch (breedKey) {
          case 'breedToyPoodle':
          case 'breedChihuahua':
            // 小型犬：クラシックの優しい楽器
            instruments.addAll(['piano', 'harp', 'violin']);
          case 'breedShiba':
            // 日本犬：クラシックの平和な楽器
            instruments.addAll(['strings', 'piano', 'cello']);
          case 'breedMiniatureDachshund':
            // 小型犬：クラシックの優しい楽器
            instruments.addAll(['piano', 'harp', 'violin']);
          case 'breedPomeranian':
            // 超小型犬：より繊細な楽器
            instruments.addAll(['harp', 'violin', 'piano']);
          case 'breedFrenchBulldog':
            // 短頭種：穏やかな楽器
            instruments.addAll(['piano', 'strings', 'cello']);
          case 'breedGoldenRetriever':
          case 'breedLabradorRetriever':
          case 'breedLabrador':
            // 大型犬：レゲエの温かい楽器
            instruments.addAll(['bass', 'acoustic_guitar', 'strings']);
          case 'breedMix':
            // 混種犬：汎用的な楽器
            instruments.addAll(['piano', 'strings', 'acoustic_guitar']);
          case 'breedOther':
            // その他の犬種：汎用的な楽器
            instruments.addAll(['piano', 'strings', 'acoustic_guitar']);
          case 'breedAkita':
            // 日本犬：クラシックの平和な楽器
            instruments.addAll(['strings', 'piano', 'cello']);
          case 'breedMaltese':
            // 超小型犬：より繊細な楽器
            instruments.addAll(['harp', 'violin', 'piano']);
          case 'breedSiberianHusky':
          case 'breedAlaskanMalamute':
            // 北方犬：力強い楽器
            instruments.addAll(['bass', 'percussion', 'strings']);
          case 'breedBorderCollie':
          case 'breedAustralianShepherd':
            // 作業犬：集中力を高める楽器
            instruments.addAll(['acoustic_guitar', 'piano', 'strings']);
          case 'breedBulldog':
          case 'breedPug':
            // 短頭種：穏やかな楽器
            instruments.addAll(['piano', 'strings', 'cello']);
          case 'breedGermanShepherd':
          case 'breedDoberman':
            // 護衛犬：自信を与える楽器
            instruments.addAll(['bass', 'strings', 'piano']);
          case 'breedBeagle':
          case 'breedDachshund':
            // 猟犬：注意力を高める楽器
            instruments.addAll(['acoustic_guitar', 'piano', 'strings']);
          case 'breedSamoyed':
          case 'breedGreatPyrenees':
            // 大型犬：威厳のある楽器
            instruments.addAll(['strings', 'bass', 'piano']);
          case 'breedCorgi':
          case 'breedWelshCorgi':
            // 牧羊犬：活発な楽器
            instruments.addAll(['acoustic_guitar', 'percussion', 'piano']);
          case 'breedShihTzu':
          case 'breedPekingese':
            // 古代犬：伝統的な楽器
            instruments.addAll(['strings', 'piano', 'harp']);
          case 'breedBerneseMountainDog':
          case 'breedSaintBernard':
            // 山岳犬：力強い楽器
            instruments.addAll(['bass', 'strings', 'piano']);
          case 'breedBostonTerrier':
            // コンパニオン犬：友好的な楽器
            instruments.addAll(['acoustic_guitar', 'piano', 'strings']);
          case 'breedWestHighlandWhiteTerrier':
          case 'breedYorkshireTerrier':
            // テリア：活発な楽器
            instruments.addAll(['acoustic_guitar', 'percussion', 'piano']);
          case 'breedNewfoundland':
          case 'breedRetriever':
            // 水犬：流れるような楽器
            instruments.addAll(['strings', 'piano', 'harp']);
          case 'breedShetlandSheepdog':
          case 'breedCollie':
            // 知能犬：洗練された楽器
            instruments.addAll(['strings', 'piano', 'acoustic_guitar']);
          case 'breedBassetHound':
          case 'breedBloodhound':
            // 嗅覚犬：深い楽器
            instruments.addAll(['cello', 'bass', 'piano']);
          case 'breedGreyhound':
          case 'breedWhippet':
            // 視覚犬：素早い楽器
            instruments.addAll(['acoustic_guitar', 'percussion', 'piano']);
          default:
            // その他の犬種：汎用的な楽器
            instruments.addAll(['piano', 'strings', 'acoustic_guitar']);
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
}

/// MusicGenerationFactoryを提供するProvider
final Provider<MusicGenerationFactory> musicGenerationFactoryProvider =
    Provider(MusicGenerationFactory.new);
