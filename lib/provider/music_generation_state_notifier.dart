// ignore_for_file: unawaited_futures, lines_longer_than_80_chars

import 'dart:async'; // Completerのために追加
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart'; // Add this import back

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
      ..d('=== Magenta.js 音楽生成リクエスト開始 ===')
      ..d('リクエスト情報:')
      ..d('  - userId: ${request.userId}')
      ..d('  - dogId: ${request.dogId}')
      ..d('  - dogBreed: ${request.dogBreed}')
      ..d('  - dogPersonalityTraits: ${request.dogPersonalityTraits}')
      ..d('  - scenario: ${request.scenario}')
      ..d('  - dogCondition: ${request.dogCondition}')
      ..d('  - additionalInfo: ${request.additionalInfo}');

    state = const AsyncValue.loading();
    _currentRequest = request; // Store the request

    try {
      // 音楽生成ファクトリーを取得
      final musicFactory = ref.read(musicGenerationFactoryProvider);

      // 利用可能なサービスを確認
      final availableServices = await musicFactory.getAvailableServices();
      logger.d('利用可能な音楽生成サービス: $availableServices');

      // 犬の情報を基にプロンプトを生成
      final prompt = _generatePromptFromRequest(request);

      // 音楽生成設定
      final config = {
        'density': 0.5,
        'brightness': 0.5,
        'bpm': 120,
        'scale': 'C_MAJOR_A_MINOR',
        'temperature': 1.1,
        'top_k': 40,
        'key': 'C',
        'mode': 'major',
        'reverb': 0.3,
        'delay': 0.1,
        'mute_bass': false,
        'mute_drums': false,
        'only_bass_and_drums': false,
        'seed': DateTime.now().millisecondsSinceEpoch % 1000000,
      };

      logger
        ..d('音楽生成APIリクエスト送信')
        ..d('プロンプト: $prompt')
        ..d('設定: $config');

      // ファクトリーを使用して音楽を生成（Magenta.jsを優先）
      final result = await musicFactory.generateMusic(
        prompt: prompt,
        config: config,
      );

      logger.d('Magenta.js音楽生成結果: $result');

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
    } on Exception catch (e, st) {
      logger.e('Google AI音楽生成エラー', error: e, stackTrace: st);

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

    // シーンに基づく音楽スタイルの選択
    var musicStyle = '';
    switch (scenario) {
      case '留守番中':
        musicStyle =
            'Calm ambient music with gentle nature sounds, soft piano melodies, peaceful atmosphere';
      case '就寝前':
        musicStyle =
            'Peaceful lullaby with soft strings and gentle rhythms, sleep-inducing';
      case 'ストレスフル':
        musicStyle =
            'Soothing meditation music with calming frequencies and gentle waves, stress-relieving';
      case '長距離移動中':
        musicStyle =
            'Relaxing travel music with smooth jazz elements and soft percussion, calming';
      case '日常の癒し':
        musicStyle =
            'Healing music with warm tones and gentle harmonies, therapeutic';
      case '療養/高齢犬ケア':
        musicStyle =
            'Therapeutic music with soft classical elements and gentle melodies, healing';
      default:
        musicStyle = 'Gentle, calming music with soft melodies, peaceful';
    }

    // 犬の状態に基づく調整
    var conditionModifier = '';
    switch (condition) {
      case '落ち着かせたい':
        conditionModifier =
            'with deep, slow rhythms and low frequencies, calming';
      case 'リラックスさせたい':
        conditionModifier =
            'with flowing melodies and peaceful harmonies, relaxing';
      case '興奮を抑えたい':
        conditionModifier =
            'with steady, calming beats and smooth transitions, soothing';
      case '安心させたい':
        conditionModifier =
            'with warm, comforting tones and gentle progressions, reassuring';
      case '安眠させたい':
        conditionModifier =
            'with dreamy, sleep-inducing sounds and soft dynamics, peaceful';
      default:
        conditionModifier = 'with gentle, soothing qualities, calming';
    }

    // 犬種に基づく調整
    var breedModifier = '';
    if (breed.contains('チワワ') || breed.contains('トイプードル')) {
      breedModifier =
          'specially designed for small dogs with higher-pitched calming sounds, gentle';
    } else if (breed.contains('ゴールデン') || breed.contains('ラブラドール')) {
      breedModifier =
          'tailored for large, gentle dogs with warm, deep tones, comforting';
    } else if (breed.contains('柴犬') || breed.contains('秋田')) {
      breedModifier =
          'adapted for Japanese breeds with traditional, peaceful elements, serene';
    } else {
      breedModifier =
          'suitable for all dog breeds with universal calming properties, gentle';
    }

    // 汎用的な音楽生成プロンプトを構築
    final prompt =
        '''
Generate calming music for a dog with the following characteristics:
- Music style: $musicStyle $conditionModifier
- Dog breed: $breed ($breedModifier)
- Dog personality: $personalityTraits
- Additional context: ${additionalInfo?.isNotEmpty == true ? additionalInfo : 'No additional information provided'}

Requirements:
- Create 30 seconds of continuous, flowing music
- Use gentle melodies and soft dynamics
- Avoid sudden changes or loud elements
- Ensure the music is calming and peaceful
- Suitable for dogs of all ages and sizes
- Use smooth transitions throughout the piece
- Focus on creating a soothing atmosphere

The music should help the dog feel calm, relaxed, and comfortable in the given scenario.
'''.trim();

    logger.d('生成された音楽生成プロンプト: $prompt');
    return prompt;
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

    logger
      ..d('現在のリクエスト情報:')
      ..d('  - userId: ${_currentRequest!.userId}')
      ..d('  - dogId: ${_currentRequest!.dogId}')
      ..d('  - scenario: ${_currentRequest!.scenario}')
      ..d('  - dogCondition: ${_currentRequest!.dogCondition}')
      ..d('  - dogBreed: ${_currentRequest!.dogBreed}');

    try {
      // JSONメッセージをパース
      final jsonData = jsonDecode(message) as Map<String, dynamic>;
      final base64MusicData = jsonData['data'] as String;

      // 生成設定情報も取得（オプション）
      final generationConfig =
          jsonData['generation_config'] as Map<String, dynamic>?;

      logger
        ..d('音楽データを受信しました。Base64データの長さ: ${base64MusicData.length}')
        ..d('Base64データの先頭50文字: ${base64MusicData.substring(0, 50)}...')
        ..d('生成設定情報: $generationConfig');

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
      _currentRequest = null; // Clear the request

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
    _currentRequest = null; // Clear the request
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
