// ignore_for_file: unawaited_futures, lines_longer_than_80_chars

import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../import/model.dart';
import '../import/provider.dart';
import '../import/utility.dart';

/// 音楽生成のStateNotifier
class MusicGenerationStateNotifier
    extends StateNotifier<AsyncValue<MusicGenerationHistory?>> {
  /// MusicGenerationStateNotifierのコンストラクタ
  MusicGenerationStateNotifier(this.ref) : super(const AsyncValue.data(null));

  /// RiverpodのRefインスタンス
  final Ref ref;

  // Store the current request to use when music generation completes
  MusicGenerationRequest? _currentRequest;

  /// 音楽生成メソッド
  ///
  /// [request] 音楽生成リクエスト
  Future<void> generateMusic(MusicGenerationRequest request) async {
    logger
      ..d('=== 音楽生成リクエスト開始 ===')
      ..d(
        'リクエスト情報: userId: ${request.userId} dogId: ${request.dogId} dogBreed: ${request.dogBreed} dogPersonalityTraits: ${request.dogPersonalityTraits} scenario: ${request.scenario} dogCondition: ${request.dogCondition} additionalInfo: ${request.additionalInfo}',
      );

    state = const AsyncValue.loading();
    _currentRequest = request; // Store the request

    try {
      // 音楽生成ファクトリーを取得
      final musicFactory = ref.read(musicGenerationFactoryProvider);

      // 犬の情報を基にプロンプトを生成
      final prompt = _generatePromptFromRequest(request);

      // 音楽生成設定
      final config = _generateConfigFromRequest(request);

      logger
        ..d('音楽生成APIリクエスト送信')
        ..d('プロンプト: $prompt')
        ..d('設定: $config');

      // ファクトリーを使用して音楽を生成（
      final result = await musicFactory.generateMusic(
        prompt: prompt,
        config: config,
      );

      // 結果を処理
      final musicData = result['audio_data'] as String;
      final generationConfig =
          result['generation_config'] as Map<String, dynamic>;

      final message = jsonEncode({
        'type': 'generated_music',
        'data': musicData,
        'generation_config': generationConfig,
      });

      await musicGenerationCompleted(message);
    } on Exception catch (e) {
      String errorMessage;
      if (e.toString().contains('APIキーが設定されていません')) {
        errorMessage = '音楽生成APIキーが設定されていません。設定を確認してください。';
      } else if (e.toString().contains('403') ||
          e.toString().contains('PERMISSION_DENIED') ||
          e.toString().contains('unauthorized')) {
        errorMessage = '音楽生成APIキーが無効です。正しいAPIキーを設定してください。';
      } else if (e.toString().contains('quota') ||
          e.toString().contains('exceeded')) {
        errorMessage =
            '音楽生成APIの使用量制限に達しました。しばらく待ってから再試行するか、有料プランへの移行を検討してください。';
      } else if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        errorMessage = 'ネットワークエラーが発生しました。インターネット接続を確認してください。';
      } else if (e.toString().contains('利用可能な音楽生成サービスがありません')) {
        errorMessage = '利用可能な音楽生成サービスがありません。APIキーを確認してください。';
      } else {
        errorMessage = '音楽生成中にエラーが発生しました: $e';
      }

      musicGenerationFailed(errorMessage);
    }
  }

  /// リクエスト情報からプロンプトを生成するメソッド
  String _generatePromptFromRequest(MusicGenerationRequest request) {
    final scenario = request.scenario;
    final condition = request.dogCondition;
    final breed = request.dogBreed;
    final personalityTraits = request.dogPersonalityTraits.join(', ');
    final additionalInfo = request.additionalInfo;

    // 多言語キーから日本語文字列へのマッピング
    final scenarioKey = _getScenarioKey(scenario);
    final conditionKey = _getConditionKey(condition);
    final breedKey = _getBreedKey(breed);

    // シーンに基づく音楽スタイルの選択（レゲエ、ソフトロック、クラシックを重視）
    var musicStyle = '';
    switch (scenarioKey) {
      case 'sceneLeavingHome':
        musicStyle =
            'Gentle reggae-inspired music with soft offbeat rhythms, warm bass lines and peaceful atmosphere, similar to Bob Marley\'s calming songs';
      case 'sceneBedtime':
        musicStyle =
            'Soft classical lullaby with gentle strings, warm cello harmonies and peaceful piano melodies, inspired by Debussy\'s peaceful compositions';
      case 'sceneStressful':
        musicStyle =
            'Calming soft rock with gentle acoustic guitar, warm vocals and soothing rhythms, similar to Jack Johnson\'s peaceful songs';
      case 'sceneLongDistanceTravel':
        musicStyle =
            'Relaxing reggae with smooth bass lines, gentle percussion and warm harmonies, inspired by peaceful reggae artists';
      case 'sceneDailyHealing':
        musicStyle =
            'Healing classical music with warm string quartets, gentle piano and soft woodwinds, therapeutic and peaceful';
      case 'sceneCare':
        musicStyle =
            'Therapeutic soft rock with gentle acoustic instruments, warm harmonies and peaceful melodies, healing and comforting';
      case 'sceneThunderFireworks':
        musicStyle =
            'Soothing classical music with deep bass tones and gentle strings, designed to mask loud noises and provide comfort';
      case 'sceneSeparationAnxiety':
        musicStyle =
            'Warm soft rock with comforting acoustic guitar and gentle vocals, creating a sense of security and companionship';
      case 'sceneNewEnvironment':
        musicStyle =
            'Calming reggae with steady rhythms and warm harmonies, helping dogs feel grounded in unfamiliar surroundings';
      case 'scenePostExercise':
        musicStyle =
            'Relaxing classical music with gentle piano and soft strings, perfect for post-exercise relaxation';
      case 'sceneGrooming':
        musicStyle =
            'Peaceful soft rock with gentle acoustic melodies, creating a calm atmosphere for grooming sessions';
      case 'sceneMealTime':
        musicStyle =
            'Gentle classical music with soft woodwinds and strings, enhancing the dining experience';
      case 'scenePlayTime':
        musicStyle =
            'Upbeat reggae with cheerful rhythms and warm harmonies, encouraging playful energy';
      case 'sceneTraining':
        musicStyle =
            'Focused soft rock with steady beats and clear melodies, aiding concentration during training';
      case 'sceneGuests':
        musicStyle =
            'Welcoming classical music with warm string arrangements, creating a hospitable atmosphere';
      case 'sceneBadWeather':
        musicStyle =
            'Comforting soft rock with gentle acoustic guitar, providing solace during bad weather';
      case 'sceneSeasonalChange':
        musicStyle =
            'Adaptive classical music with seasonal themes, helping dogs adjust to changing weather';
      case 'scenePuppySocialization':
        musicStyle =
            'Gentle reggae with playful rhythms and warm tones, supporting puppy socialization';
      case 'sceneSeniorCare':
        musicStyle =
            'Nurturing soft rock with gentle melodies and warm harmonies, specially designed for senior dogs';
      case 'sceneMultipleDogs':
        musicStyle =
            'Balanced classical music with harmonious arrangements, promoting peace among multiple dogs';
      case 'sceneVetVisit':
        musicStyle =
            'Calming soft rock with reassuring tones, reducing anxiety before veterinary visits';
      default:
        musicStyle =
            'Gentle, calming music with soft melodies and warm harmonies, peaceful';
    }

    // 犬の状態に基づく調整（レゲエ、ソフトロック、クラシックの要素を組み合わせ）
    var conditionModifier = '';
    switch (conditionKey) {
      case 'conditionCalmDown':
        conditionModifier =
            'with deep reggae bass rhythms and soft classical strings, calming and grounding';
      case 'conditionRelax':
        conditionModifier =
            'with flowing soft rock melodies and peaceful classical harmonies, relaxing and warm';
      case 'conditionSuppressExcitement':
        conditionModifier =
            'with steady reggae offbeat rhythms and gentle classical progressions, soothing and steady';
      case 'conditionReassure':
        conditionModifier =
            'with warm soft rock tones and comforting classical instruments, reassuring and peaceful';
      case 'conditionGoodSleep':
        conditionModifier =
            'with dreamy classical lullabies and soft rock ballads, peaceful and sleep-inducing';
      case 'conditionConcentration':
        conditionModifier =
            'with focused classical melodies and steady soft rock rhythms, enhancing concentration';
      case 'conditionSocialization':
        conditionModifier =
            'with welcoming reggae rhythms and friendly classical harmonies, promoting social interaction';
      case 'conditionLearning':
        conditionModifier =
            'with structured classical arrangements and clear soft rock patterns, supporting learning';
      case 'conditionExercise':
        conditionModifier =
            'with energetic reggae beats and motivating soft rock rhythms, encouraging activity';
      case 'conditionAppetite':
        conditionModifier =
            'with appetizing classical melodies and warm soft rock tones, enhancing dining experience';
      case 'conditionPainRelief':
        conditionModifier =
            'with therapeutic classical harmonies and soothing soft rock melodies, providing pain relief';
      case 'conditionAnxietyRelief':
        conditionModifier =
            'with reassuring reggae rhythms and comforting classical strings, alleviating anxiety';
      case 'conditionStressRelief':
        conditionModifier =
            'with stress-relieving classical compositions and calming soft rock harmonies';
      case 'conditionImmunity':
        conditionModifier =
            'with healing classical melodies and restorative soft rock harmonies, supporting health';
      case 'conditionMemory':
        conditionModifier =
            'with memory-enhancing classical patterns and structured soft rock arrangements';
      case 'conditionEmotionalStability':
        conditionModifier =
            'with emotionally stabilizing classical harmonies and balanced soft rock melodies';
      case 'conditionCuriosity':
        conditionModifier =
            'with intriguing classical variations and engaging soft rock rhythms, sparking curiosity';
      case 'conditionPatience':
        conditionModifier =
            'with steady classical progressions and patient soft rock rhythms, building endurance';
      case 'conditionCooperation':
        conditionModifier =
            'with harmonious classical arrangements and cooperative soft rock melodies';
      case 'conditionIndependence':
        conditionModifier =
            'with confident classical themes and independent soft rock harmonies';
      case 'conditionLove':
        conditionModifier =
            'with loving classical melodies and affectionate soft rock harmonies, deepening bonds';
      default:
        conditionModifier =
            'with gentle, soothing qualities using soft instruments, calming';
    }

    // 犬種に基づく調整（レゲエ、ソフトロック、クラシックの要素を組み合わせ）
    var breedModifier = '';
    switch (breedKey) {
      case 'breedChihuahua':
      case 'breedToyPoodle':
        breedModifier =
            'specially designed for small dogs with gentle classical melodies and soft rock harmonies, gentle and comforting';
      case 'breedGoldenRetriever':
      case 'breedLabrador':
        breedModifier =
            'tailored for large, gentle dogs with warm reggae bass and soft classical strings, comforting and grounding';
      case 'breedShibaInu':
      case 'breedAkita':
        breedModifier =
            'adapted for Japanese breeds with peaceful classical elements and gentle soft rock melodies, serene and calming';
      case 'breedPomeranian':
      case 'breedMaltese':
        breedModifier =
            'designed for tiny breeds with delicate classical melodies and gentle soft rock harmonies, ultra-gentle';
      case 'breedSiberianHusky':
      case 'breedAlaskanMalamute':
        breedModifier =
            'tailored for northern breeds with strong classical themes and powerful soft rock rhythms, energizing';
      case 'breedBorderCollie':
      case 'breedAustralianShepherd':
        breedModifier =
            'adapted for working breeds with focused classical arrangements and active soft rock rhythms, stimulating';
      case 'breedBulldog':
      case 'breedPug':
        breedModifier =
            'designed for brachycephalic breeds with gentle classical melodies and relaxed soft rock harmonies, easy-going';
      case 'breedGermanShepherd':
      case 'breedDoberman':
        breedModifier =
            'tailored for guardian breeds with protective classical themes and confident soft rock harmonies, reassuring';
      case 'breedBeagle':
      case 'breedDachshund':
        breedModifier =
            'adapted for hunting breeds with alert classical melodies and focused soft rock rhythms, attentive';
      case 'breedSamoyed':
      case 'breedGreatPyrenees':
        breedModifier =
            'designed for gentle giants with majestic classical themes and warm soft rock harmonies, majestic';
      case 'breedCorgi':
      case 'breedWelshCorgi':
        breedModifier =
            'tailored for herding breeds with energetic classical melodies and lively soft rock rhythms, spirited';
      case 'breedShihTzu':
      case 'breedPekingese':
        breedModifier =
            'adapted for ancient breeds with traditional classical themes and dignified soft rock harmonies, dignified';
      case 'breedBerneseMountainDog':
      case 'breedSaintBernard':
        breedModifier =
            'designed for mountain breeds with robust classical themes and hearty soft rock harmonies, strong';
      case 'breedBostonTerrier':
      case 'breedFrenchBulldog':
        breedModifier =
            'tailored for companion breeds with friendly classical melodies and cheerful soft rock harmonies, sociable';
      case 'breedWestHighlandWhiteTerrier':
      case 'breedYorkshireTerrier':
        breedModifier =
            'adapted for terrier breeds with spirited classical melodies and feisty soft rock rhythms, spirited';
      case 'breedNewfoundland':
      case 'breedRetriever':
        breedModifier =
            'designed for water breeds with flowing classical melodies and smooth soft rock harmonies, fluid';
      case 'breedShetlandSheepdog':
      case 'breedCollie':
        breedModifier =
            'tailored for intelligent breeds with sophisticated classical arrangements and thoughtful soft rock melodies, smart';
      case 'breedBassetHound':
      case 'breedBloodhound':
        breedModifier =
            'adapted for scent hounds with deep classical tones and resonant soft rock harmonies, deep';
      case 'breedGreyhound':
      case 'breedWhippet':
        breedModifier =
            'designed for sight hounds with swift classical melodies and agile soft rock rhythms, swift';
      default:
        breedModifier =
            'suitable for all dog breeds with universal calming properties using reggae, soft rock and classical elements, gentle';
    }

    // 汎用的な音楽生成プロンプトを構築（レゲエ、ソフトロック、クラシックを重視）
    final prompt =
        '''
Generate calming music for a dog with the following characteristics:
- Music style: $musicStyle $conditionModifier
- Dog breed: $breed ($breedModifier)
- Dog personality: $personalityTraits
- Additional context: ${additionalInfo?.isNotEmpty == true ? additionalInfo : 'No additional information provided'}

Requirements:
- Create 30 seconds of continuous, flowing music with clear musical structure
- Use gentle melodies with natural melodic contours and variations
- Incorporate harmonic progressions that create emotional depth
- Include rhythmic variations while maintaining steady tempo
- Layer multiple instruments to create rich musical textures
- Use dynamic changes to create musical interest without being jarring
- Ensure smooth transitions between musical phrases
- Focus on creating a soothing atmosphere with musical sophistication
- Incorporate elements from reggae (gentle offbeat rhythms, warm bass), soft rock (acoustic guitars, warm harmonies), and classical (string instruments, peaceful melodies)
- Vary the instrumentation to create diverse musical textures
- Include a mix of acoustic and electronic elements when appropriate
- Emphasize warm, comforting tones that dogs respond well to
- Create musical phrases with clear beginnings, developments, and resolutions
- Use chord progressions that evoke emotional responses
- Include melodic variations and counter-melodies for musical interest
- Maintain musical coherence while providing gentle surprises

The music should help the dog feel calm, relaxed, and comfortable in the given scenario, drawing inspiration from the proven calming effects of reggae, soft rock, and classical music on dogs. The composition should feel like a complete musical piece rather than a repetitive loop.
'''.trim();

    logger.d('生成された音楽生成プロンプト: $prompt');
    return prompt;
  }

  /// リクエスト情報に基づいて音楽生成設定を動的に調整するメソッド
  Map<String, dynamic> _generateConfigFromRequest(
    MusicGenerationRequest request,
  ) {
    final scenario = request.scenario;
    final condition = request.dogCondition;
    final breed = request.dogBreed;

    // 多言語キーから日本語文字列へのマッピング
    final scenarioKey = _getScenarioKey(scenario);
    final conditionKey = _getConditionKey(condition);
    final breedKey = _getBreedKey(breed);

    // 基本設定（レゲエ、ソフトロック、クラシックに適したパラメータ）
    final config = <String, dynamic>{
      'density': 0.5,
      'brightness': 0.5,
      'bpm': 120,
      'scale': 'C_MAJOR_A_MINOR',
      'temperature': 1.3, // より創造的な変化を促進
      'top_k': 50, // より多様な選択肢
      'key': 'C',
      'mode': 'major',
      'reverb': 0.3,
      'delay': 0.1,
      'mute_bass': false,
      'mute_drums': false,
      'only_bass_and_drums': false,
      'seed': DateTime.now().millisecondsSinceEpoch % 1000000,
      // 曲感を出すための追加パラメータ
      'melody_variation': 0.8, // メロディーの変化度
      'harmonic_complexity': 0.6, // 和声の複雑さ
      'rhythm_variation': 0.7, // リズムの変化
      'instrument_layering': 0.8, // 楽器の重ね合わせ
      'dynamic_range': 0.6, // 音量の変化
      'phrase_length': 4, // フレーズの長さ（小節数）
      'chord_progression_variety': 0.7, // コード進行の多様性
      'melodic_contour': 0.8, // メロディーの起伏
      // シーン情報を追加
      'scenario': scenario,
      'condition': condition,
      'breed': breed,
    };

    // シーンに基づく設定調整（レゲエ、ソフトロック、クラシックの特徴を反映）
    switch (scenarioKey) {
      case 'sceneLeavingHome':
        // レゲエ風：オフビートリズム、温かいベース（犬の心拍数に近いテンポ）
        config['bpm'] = 95;
        config['brightness'] = 0.6;
        config['density'] = 0.4;
        config['reverb'] = 0.3;
        config['delay'] = 0.15;
        config['mode'] = 'major';
      case 'sceneBedtime':
        // クラシック風：ゆったりとした弦楽器（落ち着いたテンポ）
        config['bpm'] = 75;
        config['brightness'] = 0.4;
        config['density'] = 0.3;
        config['reverb'] = 0.5;
        config['delay'] = 0.2;
        config['mode'] = 'major';
      case 'sceneStressful':
        // ソフトロック風：アコースティックギター、温かいハーモニー（中程度のテンポ）
        config['bpm'] = 90;
        config['brightness'] = 0.5;
        config['density'] = 0.4;
        config['reverb'] = 0.4;
        config['delay'] = 0.1;
        config['mode'] = 'major';
      case 'sceneLongDistanceTravel':
        // レゲエ風：スムーズなベースライン（安定したテンポ）
        config['bpm'] = 100;
        config['brightness'] = 0.6;
        config['density'] = 0.4;
        config['reverb'] = 0.2;
        config['delay'] = 0.1;
        config['mode'] = 'major';
      case 'sceneDailyHealing':
        // クラシック風：弦楽四重奏（バランスの取れたテンポ）
        config['bpm'] = 85;
        config['brightness'] = 0.5;
        config['density'] = 0.4;
        config['reverb'] = 0.4;
        config['delay'] = 0.15;
        config['mode'] = 'major';
      case 'sceneCare':
        // ソフトロック風：癒し系アコースティック（穏やかなテンポ）
        config['bpm'] = 80;
        config['brightness'] = 0.4;
        config['density'] = 0.3;
        config['reverb'] = 0.4;
        config['delay'] = 0.2;
        config['mode'] = 'major';
      case 'sceneThunderFireworks':
        // クラシック風：深いベーストーンで音をマスク
        config['bpm'] = 70;
        config['brightness'] = 0.3;
        config['density'] = 0.5;
        config['reverb'] = 0.6;
        config['delay'] = 0.2;
        config['mode'] = 'major';
      case 'sceneSeparationAnxiety':
        // ソフトロック風：安心感を与える温かいハーモニー
        config['bpm'] = 85;
        config['brightness'] = 0.6;
        config['density'] = 0.4;
        config['reverb'] = 0.4;
        config['delay'] = 0.15;
        config['mode'] = 'major';
      case 'sceneNewEnvironment':
        // レゲエ風：安定したリズムで安心感を提供
        config['bpm'] = 90;
        config['brightness'] = 0.5;
        config['density'] = 0.4;
        config['reverb'] = 0.3;
        config['delay'] = 0.1;
        config['mode'] = 'major';
      case 'scenePostExercise':
        // クラシック風：心拍数を下げる穏やかな音楽
        config['bpm'] = 70;
        config['brightness'] = 0.4;
        config['density'] = 0.3;
        config['reverb'] = 0.5;
        config['delay'] = 0.2;
        config['mode'] = 'major';
      case 'sceneGrooming':
        // ソフトロック風：リラックスした雰囲気
        config['bpm'] = 80;
        config['brightness'] = 0.5;
        config['density'] = 0.3;
        config['reverb'] = 0.4;
        config['delay'] = 0.15;
        config['mode'] = 'major';
      case 'sceneMealTime':
        // クラシック風：食事を楽しむ音楽
        config['bpm'] = 85;
        config['brightness'] = 0.6;
        config['density'] = 0.4;
        config['reverb'] = 0.3;
        config['delay'] = 0.1;
        config['mode'] = 'major';
      case 'scenePlayTime':
        // レゲエ風：楽しいリズムで遊びを促進
        config['bpm'] = 105;
        config['brightness'] = 0.7;
        config['density'] = 0.5;
        config['reverb'] = 0.2;
        config['delay'] = 0.1;
        config['mode'] = 'major';
        // 曲感を出すための追加設定
        config['melody_variation'] = 0.9; // 遊び時間はメロディーの変化を多く
        config['rhythm_variation'] = 0.8; // リズムの変化も多く
        config['harmonic_complexity'] = 0.7; // 和声も少し複雑に
        config['dynamic_range'] = 0.7; // 音量の変化も多く
        config['phrase_length'] = 2; // 短いフレーズで活発に
        config['chord_progression_variety'] = 0.8; // コード進行の多様性
        config['melodic_contour'] = 0.9; // メロディーの起伏を大きく
      case 'sceneTraining':
        // ソフトロック風：集中力を高める音楽
        config['bpm'] = 95;
        config['brightness'] = 0.6;
        config['density'] = 0.4;
        config['reverb'] = 0.3;
        config['delay'] = 0.1;
        config['mode'] = 'major';
      case 'sceneGuests':
        // クラシック風：歓迎の音楽
        config['bpm'] = 90;
        config['brightness'] = 0.6;
        config['density'] = 0.4;
        config['reverb'] = 0.4;
        config['delay'] = 0.15;
        config['mode'] = 'major';
      case 'sceneBadWeather':
        // ソフトロック風：慰めの音楽
        config['bpm'] = 80;
        config['brightness'] = 0.4;
        config['density'] = 0.3;
        config['reverb'] = 0.5;
        config['delay'] = 0.2;
        config['mode'] = 'major';
      case 'sceneSeasonalChange':
        // クラシック風：季節に適応する音楽
        config['bpm'] = 85;
        config['brightness'] = 0.5;
        config['density'] = 0.4;
        config['reverb'] = 0.4;
        config['delay'] = 0.15;
        config['mode'] = 'major';
      case 'scenePuppySocialization':
        // レゲエ風：子犬の好奇心を刺激
        config['bpm'] = 100;
        config['brightness'] = 0.7;
        config['density'] = 0.4;
        config['reverb'] = 0.3;
        config['delay'] = 0.1;
        config['mode'] = 'major';
      case 'sceneSeniorCare':
        // ソフトロック風：シニア犬に優しい音楽
        config['bpm'] = 75;
        config['brightness'] = 0.4;
        config['density'] = 0.3;
        config['reverb'] = 0.5;
        config['delay'] = 0.2;
        config['mode'] = 'major';
      case 'sceneMultipleDogs':
        // クラシック風：調和を促進する音楽
        config['bpm'] = 85;
        config['brightness'] = 0.5;
        config['density'] = 0.4;
        config['reverb'] = 0.4;
        config['delay'] = 0.15;
        config['mode'] = 'major';
      case 'sceneVetVisit':
        // ソフトロック風：不安を軽減する音楽
        config['bpm'] = 80;
        config['brightness'] = 0.5;
        config['density'] = 0.3;
        config['reverb'] = 0.4;
        config['delay'] = 0.15;
        config['mode'] = 'major';
    }

    // 犬の状態に基づく調整（レゲエ、ソフトロック、クラシックの要素を反映）
    switch (conditionKey) {
      case 'conditionCalmDown':
        // レゲエのベースリズム + クラシックの弦楽器（心拍数を下げるテンポ）
        config['bpm'] = (config['bpm'] as int) - 5;
        config['density'] = (config['density'] as double) - 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
        config['delay'] = (config['delay'] as double) + 0.05;
      case 'conditionRelax':
        // ソフトロックの温かいハーモニー（安定したテンポ）
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['delay'] = (config['delay'] as double) + 0.05;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'conditionSuppressExcitement':
        // レゲエのオフビートリズム（心拍数を下げるテンポ）
        config['bpm'] = (config['bpm'] as int) - 10;
        config['density'] = (config['density'] as double) - 0.15;
        config['delay'] = (config['delay'] as double) + 0.1;
      case 'conditionReassure':
        // ソフトロックの温かいトーン（安定したテンポ）
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
        config['delay'] = (config['delay'] as double) + 0.05;
      case 'conditionGoodSleep':
        // クラシックのララバイ（心拍数を下げるテンポ）
        config['bpm'] = (config['bpm'] as int) - 15;
        config['density'] = (config['density'] as double) - 0.2;
        config['reverb'] = (config['reverb'] as double) + 0.2;
        config['delay'] = (config['delay'] as double) + 0.1;
      case 'conditionConcentration':
        // クラシックの構造化された音楽
        config['bpm'] = (config['bpm'] as int) + 5;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) - 0.1;
      case 'conditionSocialization':
        // レゲエの友好的なリズム
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
      case 'conditionLearning':
        // クラシックの構造化された音楽
        config['bpm'] = (config['bpm'] as int) + 5;
        config['density'] = (config['density'] as double) + 0.1;
      case 'conditionExercise':
        // レゲエのエネルギッシュなリズム
        config['bpm'] = (config['bpm'] as int) + 10;
        config['brightness'] = (config['brightness'] as double) + 0.1;
      case 'conditionAppetite':
        // ソフトロックの温かいトーン
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'conditionPainRelief':
        // クラシックの治療的な音楽
        config['bpm'] = (config['bpm'] as int) - 10;
        config['reverb'] = (config['reverb'] as double) + 0.2;
        // 曲感を出すための追加設定
        config['melody_variation'] = 0.6; // 痛み軽減は穏やかなメロディー
        config['harmonic_complexity'] = 0.8; // 和声は豊かに
        config['rhythm_variation'] = 0.4; // リズムは安定
        config['dynamic_range'] = 0.5; // 音量変化は控えめ
        config['phrase_length'] = 8; // 長いフレーズで落ち着き
        config['chord_progression_variety'] = 0.6; // コード進行は穏やか
        config['melodic_contour'] = 0.5; // メロディーの起伏は控えめ
      case 'conditionAnxietyRelief':
        // レゲエの安心感を与えるリズム
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'conditionStressRelief':
        // クラシックのストレス軽減音楽
        config['bpm'] = (config['bpm'] as int) - 5;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'conditionImmunity':
        // ソフトロックの健康的な音楽
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
      case 'conditionMemory':
        // クラシックの記憶を促進する音楽
        config['bpm'] = (config['bpm'] as int) + 5;
        config['density'] = (config['density'] as double) + 0.1;
      case 'conditionEmotionalStability':
        // ソフトロックの感情を安定させる音楽
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'conditionCuriosity':
        // レゲエの好奇心を刺激するリズム
        config['bpm'] = (config['bpm'] as int) + 5;
        config['brightness'] = (config['brightness'] as double) + 0.1;
      case 'conditionPatience':
        // クラシックの忍耐力を高める音楽
        config['bpm'] = (config['bpm'] as int) - 5;
        config['density'] = (config['density'] as double) + 0.1;
      case 'conditionCooperation':
        // ソフトロックの協調性を促進する音楽
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
      case 'conditionIndependence':
        // レゲエの自立心を促進するリズム
        config['bpm'] = (config['bpm'] as int) + 5;
        config['brightness'] = (config['brightness'] as double) + 0.1;
      case 'conditionLove':
        // ソフトロックの愛情を深める音楽
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
    }

    // 犬種に基づく調整（レゲエ、ソフトロック、クラシックの要素を反映）
    switch (breedKey) {
      case 'breedChihuahua':
      case 'breedToyPoodle':
        // 小型犬：クラシックの優しいメロディー（少し速めのテンポ）
        config['bpm'] = (config['bpm'] as int) + 5;
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) - 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
        // 曲感を出すための追加設定
        config['melody_variation'] =
            (config['melody_variation'] as double) + 0.1; // 小型犬用のメロディー変化
        config['harmonic_complexity'] =
            (config['harmonic_complexity'] as double) + 0.1; // 和声の豊かさ
        config['rhythm_variation'] =
            (config['rhythm_variation'] as double) + 0.1; // リズムの変化
        config['dynamic_range'] =
            (config['dynamic_range'] as double) + 0.1; // 音量の変化
        config['phrase_length'] =
            (config['phrase_length'] as int) - 1; // 短いフレーズ
        config['chord_progression_variety'] =
            (config['chord_progression_variety'] as double) + 0.1; // コード進行の多様性
        config['melodic_contour'] =
            (config['melodic_contour'] as double) + 0.1; // メロディーの起伏
      case 'breedGoldenRetriever':
      case 'breedLabrador':
        // 大型犬：レゲエの温かいベース（安定したテンポ）
        config['brightness'] = (config['brightness'] as double) - 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'breedShibaInu':
      case 'breedAkita':
        // 日本犬：クラシックの平和な要素（穏やかなテンポ）
        config['bpm'] = (config['bpm'] as int) - 5;
        config['brightness'] = (config['brightness'] as double) - 0.05;
        config['reverb'] = (config['reverb'] as double) + 0.1;
        config['delay'] = (config['delay'] as double) + 0.05;
      case 'breedPomeranian':
      case 'breedMaltese':
        // 超小型犬：より繊細な音楽
        config['bpm'] = (config['bpm'] as int) + 10;
        config['brightness'] = (config['brightness'] as double) + 0.15;
        config['density'] = (config['density'] as double) - 0.15;
        config['reverb'] = (config['reverb'] as double) + 0.15;
      case 'breedSiberianHusky':
      case 'breedAlaskanMalamute':
        // 北方犬：力強い音楽
        config['bpm'] = (config['bpm'] as int) + 10;
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) - 0.1;
      case 'breedBorderCollie':
      case 'breedAustralianShepherd':
        // 作業犬：集中力を高める音楽
        config['bpm'] = (config['bpm'] as int) + 5;
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) - 0.1;
      case 'breedBulldog':
      case 'breedPug':
        // 短頭種：穏やかな音楽
        config['bpm'] = (config['bpm'] as int) - 5;
        config['brightness'] = (config['brightness'] as double) - 0.1;
        config['density'] = (config['density'] as double) - 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'breedGermanShepherd':
      case 'breedDoberman':
        // 護衛犬：自信を与える音楽
        config['bpm'] = (config['bpm'] as int) + 5;
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'breedBeagle':
      case 'breedDachshund':
        // 猟犬：注意力を高める音楽
        config['bpm'] = (config['bpm'] as int) + 5;
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) - 0.1;
      case 'breedSamoyed':
      case 'breedGreatPyrenees':
        // 大型犬：威厳のある音楽
        config['bpm'] = (config['bpm'] as int) - 5;
        config['brightness'] = (config['brightness'] as double) - 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'breedCorgi':
      case 'breedWelshCorgi':
        // 牧羊犬：活発な音楽
        config['bpm'] = (config['bpm'] as int) + 10;
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) - 0.1;
      case 'breedShihTzu':
      case 'breedPekingese':
        // 古代犬：伝統的な音楽
        config['bpm'] = (config['bpm'] as int) - 5;
        config['brightness'] = (config['brightness'] as double) - 0.1;
        config['density'] = (config['density'] as double) - 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'breedBerneseMountainDog':
      case 'breedSaintBernard':
        // 山岳犬：力強い音楽
        config['bpm'] = (config['bpm'] as int) - 5;
        config['brightness'] = (config['brightness'] as double) - 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'breedBostonTerrier':
      case 'breedFrenchBulldog':
        // コンパニオン犬：友好的な音楽
        config['bpm'] = (config['bpm'] as int) + 5;
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'breedWestHighlandWhiteTerrier':
      case 'breedYorkshireTerrier':
        // テリア：活発な音楽
        config['bpm'] = (config['bpm'] as int) + 10;
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) - 0.1;
      case 'breedNewfoundland':
      case 'breedRetriever':
        // 水犬：流れるような音楽
        config['bpm'] = (config['bpm'] as int) - 5;
        config['brightness'] = (config['brightness'] as double) - 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'breedShetlandSheepdog':
      case 'breedCollie':
        // 知能犬：洗練された音楽
        config['bpm'] = (config['bpm'] as int) + 5;
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'breedBassetHound':
      case 'breedBloodhound':
        // 嗅覚犬：深い音楽
        config['bpm'] = (config['bpm'] as int) - 5;
        config['brightness'] = (config['brightness'] as double) - 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) + 0.1;
      case 'breedGreyhound':
      case 'breedWhippet':
        // 視覚犬：素早い音楽
        config['bpm'] = (config['bpm'] as int) + 10;
        config['brightness'] = (config['brightness'] as double) + 0.1;
        config['density'] = (config['density'] as double) + 0.1;
        config['reverb'] = (config['reverb'] as double) - 0.1;
      default:
        // その他の犬種：汎用的な設定
        break;
    }

    // 値の範囲を制限（犬の心拍数に適した範囲）
    config['bpm'] = (config['bpm'] as int).clamp(60, 120);
    config['brightness'] = (config['brightness'] as double).clamp(0.1, 1.0);
    config['density'] = (config['density'] as double).clamp(0.1, 1.0);
    config['reverb'] = (config['reverb'] as double).clamp(0.0, 1.0);
    config['delay'] = (config['delay'] as double).clamp(0.0, 0.5);
    // 新しい音楽パラメータの範囲制限
    config['melody_variation'] = (config['melody_variation'] as double).clamp(
      0.1,
      1.0,
    );
    config['harmonic_complexity'] = (config['harmonic_complexity'] as double)
        .clamp(0.1, 1.0);
    config['rhythm_variation'] = (config['rhythm_variation'] as double).clamp(
      0.1,
      1.0,
    );
    config['instrument_layering'] = (config['instrument_layering'] as double)
        .clamp(0.1, 1.0);
    config['dynamic_range'] = (config['dynamic_range'] as double).clamp(
      0.1,
      1.0,
    );
    config['phrase_length'] = (config['phrase_length'] as int).clamp(1, 16);
    config['chord_progression_variety'] =
        (config['chord_progression_variety'] as double).clamp(0.1, 1.0);
    config['melodic_contour'] = (config['melodic_contour'] as double).clamp(
      0.1,
      1.0,
    );

    return config;
  }

  /// 音楽生成が完了したときに呼び出されるメソッド
  Future<void> musicGenerationCompleted(String message) async {
    logger.d('=== 音楽生成完了処理開始 ===');

    if (_currentRequest == null) {
      logger.e('音楽生成リクエストが見つかりません。');
      state = AsyncValue.error(
        Exception('音楽生成リクエストが見つかりません。'),
        StackTrace.current,
      );
      return;
    }

    logger.d(
      'リクエスト: - userId: ${_currentRequest!.userId} - dogId: ${_currentRequest!.dogId} - scenario: ${_currentRequest!.scenario} - dogCondition: ${_currentRequest!.dogCondition} - dogBreed: ${_currentRequest!.dogBreed}',
    );

    try {
      // JSONメッセージをパース
      final jsonData = jsonDecode(message) as Map<String, dynamic>;
      final base64MusicData = jsonData['data'] as String;

      // 生成設定情報も取得（オプション）
      final generationConfig =
          jsonData['generation_config'] as Map<String, dynamic>?;

      logger.d('生成設定情報: $generationConfig');

      // Base64データをデコードしてFirebase Storageにアップロード
      final musicBytes = base64Decode(
        base64MusicData.split(',')[1],
      ); // "data:audio/wav;base64,..." のヘッダを除去

      logger.d('音楽データをデコードしました。バイト数: ${musicBytes.length}');

      // WAV形式でファイル名を生成（最適化されたサンプリングレート）
      final fileName = 'generated_music/${const Uuid().v4()}.wav';
      final storageRef = ref
          .read(firebaseStorageProvider)
          .ref()
          .child(fileName);

      logger.d('Firebase Storageにアップロード中: $fileName');

      // WAVファイルとしてアップロード
      await storageRef.putData(musicBytes);
      final musicUrl = await storageRef.getDownloadURL();

      logger.d('音楽URLを取得しました: $musicUrl');

      final historyId = const Uuid().v4();
      logger.d('生成された履歴ID: $historyId');

      final newHistory = MusicGenerationHistory(
        id: historyId,
        userId: _currentRequest!.userId,
        dogId: _currentRequest!.dogId,
        scenario: _currentRequest!.scenario,
        dogCondition: _currentRequest!.dogCondition,
        generatedMusicUrl: musicUrl,
        duration: 30, // 実際の音楽生成時間（30秒）
        createdAt: DateTime.now(),
        dogBreed: _currentRequest!.dogBreed,
        dogPersonalityTraits: _currentRequest!.dogPersonalityTraits,
      );

      logger
        ..d('作成された履歴オブジェクト:')
        ..d('  - id: ${newHistory.id}')
        ..d('  - userId: ${newHistory.userId}')
        ..d('  - dogId: ${newHistory.dogId}')
        ..d('  - scenario: ${newHistory.scenario}')
        ..d('  - generatedMusicUrl: ${newHistory.generatedMusicUrl}')
        ..d('  - createdAt: ${newHistory.createdAt}')
        ..d('  - generationConfig: $generationConfig')
        // Save to history
        ..d('音楽生成履歴をFirestoreに保存中: ${newHistory.id}')
        ..d('Firestoreコレクション: musicGenerationHistories')
        ..d('ドキュメントID: ${newHistory.id}');

      final firestore = ref.read(firestoreProvider);
      logger.d('Firestoreインスタンス取得完了');

      final collectionRef = firestore.collection('musicGenerationHistories');
      logger.d('コレクション参照取得完了');

      final docRef = collectionRef.doc(newHistory.id);
      logger.d('ドキュメント参照取得完了');

      // 生成設定情報も含めて履歴データを構築
      final historyData = newHistory.toJson();
      if (generationConfig != null) {
        historyData['generation_config'] = generationConfig;
      }

      logger
        ..d('履歴JSON変換完了: ${historyData.keys}')
        ..d('送信するJSONデータ: $historyData');

      await docRef.set(historyData);
      logger.d('Firestoreへの保存完了');

      state = AsyncValue.data(newHistory);
      _currentRequest = null;

      logger.d('=== 音楽生成完了処理終了 ===');
    } on Exception catch (e, st) {
      logger.e('音楽生成完了処理エラー', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// 音楽生成が失敗したときに呼び出されるメソッド
  void musicGenerationFailed(String errorMessage) {
    logger.e('音楽生成失敗: $errorMessage');
    state = AsyncValue.error(
      Exception('音楽の生成に失敗しました: $errorMessage'),
      StackTrace.current,
    );
    _currentRequest = null;
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
        return 'sceneLeavingHome'; // デフォルト値
    }
  }

  /// 犬の状態文字列から多言語キーを取得するヘルパーメソッド
  String _getConditionKey(String condition) {
    switch (condition) {
      case '落ち着かせたい':
        return 'conditionCalmDown';
      case 'リラックスさせたい':
        return 'conditionRelax';
      case '興奮を抑えたい':
        return 'conditionSuppressExcitement';
      case '安心させたい':
        return 'conditionReassure';
      case '安眠させたい':
        return 'conditionGoodSleep';
      case '集中力を高めたい':
        return 'conditionConcentration';
      case '社交性を向上させたい':
        return 'conditionSocialization';
      case '学習能力を向上させたい':
        return 'conditionLearning';
      case '運動意欲を高めたい':
        return 'conditionExercise';
      case '食欲を促進させたい':
        return 'conditionAppetite';
      case '痛みを軽減させたい':
        return 'conditionPainRelief';
      case '不安を解消させたい':
        return 'conditionAnxietyRelief';
      case 'ストレスを軽減させたい':
        return 'conditionStressRelief';
      case '免疫力を向上させたい':
        return 'conditionImmunity';
      case '記憶力を向上させたい':
        return 'conditionMemory';
      case '感情を安定させたい':
        return 'conditionEmotionalStability';
      case '好奇心を刺激したい':
        return 'conditionCuriosity';
      case '忍耐力を向上させたい':
        return 'conditionPatience';
      case '協調性を高めたい':
        return 'conditionCooperation';
      case '自立心を育てたい':
        return 'conditionIndependence';
      case '愛情を深めたい':
        return 'conditionLove';
      default:
        return 'conditionCalmDown'; // デフォルト値
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

      // 超小型犬
      case 'ポメラニアン':
      case 'pomeranian':
        return 'breedPomeranian';
      case 'マルチーズ':
      case 'maltese':
        return 'breedMaltese';

      // 北方犬
      case 'シベリアンハスキー':
      case 'siberian husky':
      case 'husky':
        return 'breedSiberianHusky';
      case 'アラスカンマラミュート':
      case 'alaskan malamute':
      case 'malamute':
        return 'breedAlaskanMalamute';

      // 作業犬
      case 'ボーダーコリー':
      case 'border collie':
      case 'bordercollie':
        return 'breedBorderCollie';
      case 'オーストラリアンシェパード':
      case 'australian shepherd':
      case 'aussie':
        return 'breedAustralianShepherd';

      // 短頭種
      case 'ブルドッグ':
      case 'bulldog':
        return 'breedBulldog';
      case 'パグ':
      case 'pug':
        return 'breedPug';

      // 護衛犬
      case 'ジャーマンシェパード':
      case 'german shepherd':
      case 'germanshepherd':
        return 'breedGermanShepherd';
      case 'ドーベルマン':
      case 'doberman':
        return 'breedDoberman';

      // 猟犬
      case 'ビーグル':
      case 'beagle':
        return 'breedBeagle';
      case 'ダックスフンド':
      case 'dachshund':
        return 'breedDachshund';

      // 大型犬
      case 'サモエド':
      case 'samoyed':
        return 'breedSamoyed';
      case 'グレートピレニーズ':
      case 'great pyrenees':
      case 'pyrenees':
        return 'breedGreatPyrenees';

      // 牧羊犬
      case 'コーギー':
      case 'corgi':
        return 'breedCorgi';
      case 'ウェルシュコーギー':
      case 'welsh corgi':
      case 'welshcorgi':
        return 'breedWelshCorgi';

      // 古代犬
      case 'シーズー':
      case 'shih tzu':
      case 'shihtzu':
        return 'breedShihTzu';
      case 'ペキニーズ':
      case 'pekingese':
        return 'breedPekingese';

      // 山岳犬
      case 'バーニーズマウンテンドッグ':
      case 'berner sennenhund':
      case 'berner':
        return 'breedBerneseMountainDog';
      case 'セントバーナード':
      case 'saint bernard':
      case 'saintbernard':
        return 'breedSaintBernard';

      // コンパニオン犬
      case 'ボストンテリア':
      case 'boston terrier':
      case 'bostonterrier':
        return 'breedBostonTerrier';
      case 'フレンチブルドッグ':
      case 'french bulldog':
      case 'frenchie':
        return 'breedFrenchBulldog';

      // テリア
      case 'ホワイトテリア':
      case 'west highland white terrier':
      case 'westie':
        return 'breedWestHighlandWhiteTerrier';
      case 'ヨークシャーテリア':
      case 'yorkshire terrier':
      case 'yorkie':
        return 'breedYorkshireTerrier';

      // 水犬
      case 'ニューファンドランド':
      case 'newfoundland':
        return 'breedNewfoundland';
      case 'レトリーバー':
      case 'retriever':
        return 'breedRetriever';

      // 知能犬
      case 'シェットランドシープドッグ':
      case 'shetland sheepdog':
      case 'sheltie':
        return 'breedShetlandSheepdog';
      case 'コリー':
      case 'collie':
        return 'breedCollie';

      // 嗅覚犬
      case 'バセットハウンド':
      case 'basset hound':
      case 'bassethound':
        return 'breedBassetHound';
      case 'ブラッドハウンド':
      case 'bloodhound':
        return 'breedBloodhound';

      // 視覚犬
      case 'グレイハウンド':
      case 'greyhound':
        return 'breedGreyhound';
      case 'ウィペット':
      case 'whippet':
        return 'breedWhippet';

      default:
        return 'breedGeneric'; // デフォルト値
    }
  }
}

/// MusicGenerationStateNotifierを提供するProvider
final AutoDisposeStateNotifierProvider<
  MusicGenerationStateNotifier,
  AsyncValue<MusicGenerationHistory?>
>
musicGenerationStateNotifierProvider = StateNotifierProvider.autoDispose<
  MusicGenerationStateNotifier,
  AsyncValue<MusicGenerationHistory?>
>(MusicGenerationStateNotifier.new);

/// 音楽生成履歴を取得するStreamProvider
final AutoDisposeStreamProvider<List<MusicGenerationHistory>>
musicHistoryStreamProvider =
    StreamProvider.autoDispose<List<MusicGenerationHistory>>((ref) {
      final userId = ref.watch(authStateChangesProvider).value?.uid;
      logger.d('=== 音楽履歴取得開始 ユーザーID: $userId ===');
      if (userId == null) {
        logger.d('ユーザーIDがnullのため、空のリストを返します');
        return Stream.value([]);
      }

      try {
        final firestore = ref.read(firestoreProvider);
        final collectionRef = firestore.collection('musicGenerationHistories');

        // ユーザーIDでフィルタリング
        final query = collectionRef.where('user_id', isEqualTo: userId);
        return query
            .snapshots()
            .map((snapshot) {
              final historyList =
                  snapshot.docs
                      .map((doc) {
                        try {
                          final history = MusicGenerationHistory.fromJson(
                            doc.data(),
                          );
                          return history;
                        } on Exception catch (e) {
                          logger.e('ドキュメントのパースエラー: ${doc.id}', error: e);
                          return null;
                        }
                      })
                      .where((history) => history != null)
                      .cast<MusicGenerationHistory>()
                      .where((history) {
                        final matches = history.userId == userId;
                        return matches;
                      }) // クライアントサイドでフィルタリング
                      .toList()
                    ..sort(
                      (a, b) => b.createdAt.compareTo(a.createdAt),
                    ); // 最新順にソート

              logger.d('=== 音楽履歴取得完了 ===');
              return historyList;
            })
            .handleError((Object error, StackTrace stackTrace) {
              // Firestoreの権限エラーが発生した場合、空のリストを返し、エラーをログに記録します。
              // これにより、アプリがクラッシュするのを防ぎますが、
              // 履歴機能はFirestoreのルールが修正されるまで機能しません。
              logger.e(
                'Failed to fetch music history due to permission error',
                error: error,
                stackTrace: stackTrace,
              );
              return <MusicGenerationHistory>[];
            });
      } on Exception catch (e, st) {
        logger.e(
          'An unexpected error occurred while fetching music history',
          error: e,
          stackTrace: st,
        );
        return Stream.value([]);
      }
    });

/// 特定の音楽IDで音楽履歴を取得するStreamProvider
final AutoDisposeStreamProviderFamily<MusicGenerationHistory?, String>
musicHistoryByIdStreamProvider = StreamProvider.autoDispose
    .family<MusicGenerationHistory?, String>((ref, musicId) {
      final userId = ref.watch(authStateChangesProvider).value?.uid;
      logger.d('=== 特定音楽履歴取得開始 音楽ID: $musicId, ユーザーID: $userId ===');

      if (userId == null) {
        logger.d('ユーザーIDがnullのため、nullを返します');
        return Stream.value(null);
      }

      try {
        final firestore = ref.read(firestoreProvider);
        final collectionRef = firestore.collection('musicGenerationHistories');

        return collectionRef
            .doc(musicId)
            .snapshots()
            .map((snapshot) {
              if (!snapshot.exists) {
                logger.d('音楽履歴が見つかりません: $musicId');
                return null;
              }

              try {
                final history = MusicGenerationHistory.fromJson(
                  snapshot.data()!,
                );

                // ユーザーIDの確認
                if (history.userId != userId) {
                  logger.d('ユーザーIDが一致しません: ${history.userId} != $userId');
                  return null;
                }

                logger.d('=== 特定音楽履歴取得完了 ===');
                return history;
              } on Exception catch (e) {
                logger.e('ドキュメントのパースエラー: ${snapshot.id}', error: e);
                return null;
              }
            })
            .handleError((Object error, StackTrace stackTrace) {
              logger.e(
                'Failed to fetch music history by ID due to permission error',
                error: error,
                stackTrace: stackTrace,
              );
              return null;
            });
      } on Exception catch (e, st) {
        logger.e(
          'An unexpected error occurred while fetching music history by ID',
          error: e,
          stackTrace: st,
        );
        return Stream.value(null);
      }
    });
