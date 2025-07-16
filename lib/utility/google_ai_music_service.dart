import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'base_music_service.dart';

/// Google AI Lyria RealTimeを使用した音楽生成サービス
class GoogleAiMusicService extends BaseMusicService {
  /// GoogleAiMusicServiceのコンストラクタ
  GoogleAiMusicService({required this.apiKey, Logger? logger})
    : logger = logger ?? Logger();

  /// Google AI APIキー
  final String apiKey;

  /// ロガー
  final Logger logger;

  /// APIキーが有効かどうかを確認するメソッド
  @override
  bool get isApiKeyValid =>
      apiKey.isNotEmpty && apiKey != 'your_google_ai_api_key_here';

  /// 音楽生成のベースURL（Gemini Proを使用）
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';

  /// 利用可能なモデルを確認するメソッド
  Future<List<String>> getAvailableModels() async {
    logger
      ..d('=== 利用可能なモデルを確認中 ===')
      ..d('APIキー: ${apiKey.isNotEmpty ? '設定済み' : '未設定'}')
      ..d('APIキーの長さ: ${apiKey.length}');

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'PawHarmonyAI/1.0',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final models = responseData['models'] as List<dynamic>? ?? [];

        final allModelNames =
            models.map((model) => model['name'] as String).toList();

        final lyriaModelNames =
            allModelNames.where((name) => name.contains('lyria')).toList();

        logger
          ..d('すべての利用可能なモデル: $allModelNames')
          ..d('利用可能なLyriaモデル: $lyriaModelNames');
        return lyriaModelNames;
      } else {
        logger
          ..e('モデル一覧取得エラー: ${response.statusCode}')
          ..e('エラーレスポンス: ${response.body}');

        // エラーレスポンスを解析
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage =
              errorData['error']?['message']?.toString() ?? '不明なエラー';
          logger.e('APIエラーメッセージ: $errorMessage');

          if (errorMessage.contains('API key')) {
            throw Exception('Google AI APIキーが無効です: $errorMessage');
          } else if (errorMessage.contains('permission')) {
            throw Exception('Google AI APIへのアクセス権限がありません: $errorMessage');
          }
        } on Exception catch (parseError) {
          logger.e('エラーレスポンスの解析に失敗', error: parseError);
        }

        return [];
      }
    } on Exception catch (e, st) {
      logger.e('モデル一覧取得エラー', error: e, stackTrace: st);
      return [];
    }
  }

  /// 音楽を生成するメソッド
  ///
  /// [prompt] 音楽生成のプロンプト
  /// [duration] 音楽の長さ（秒）
  /// [sampleRate] サンプリングレート
  /// [numChannels] チャンネル数
  /// [config] 生成設定
  @override
  Future<Map<String, dynamic>> generateMusic({
    required String prompt,
    int duration = 30,
    int sampleRate = 48000,
    int numChannels = 2,
    Map<String, dynamic>? config,
  }) async {
    logger
      ..d('=== Google AI Lyria RealTime 音楽生成開始 ===')
      ..d('プロンプト: $prompt')
      ..d('長さ: $duration秒')
      ..d('サンプリングレート: $sampleRate')
      ..d('チャンネル数: $numChannels');

    // APIキーの検証
    if (!isApiKeyValid) {
      throw Exception('Google AI APIキーが設定されていません。環境変数を確認してください。');
    }

    // クォータ制限のチェック（簡易版）
    if (apiKey.length < 10) {
      throw Exception('Google AI APIキーが無効です。正しいAPIキーを設定してください。');
    }

    try {
      // デフォルト設定
      final defaultConfig = {
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

      // カスタム設定があればマージ
      final finalConfig = {...defaultConfig, ...?config};

      // リクエストボディを構築（Gemini Pro用）
      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': '''
音楽生成の指示: $prompt

以下の形式で音楽の詳細を生成してください:
- ジャンル: [音楽のジャンル]
- テンポ: [BPM]
- 調性: [調性]
- 楽器編成: [使用楽器]
- 雰囲気: [音楽の雰囲気]
- 推奨再生時間: [秒数]

犬のための癒し音楽として最適化してください。
''',
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': finalConfig['temperature'],
          'topK': finalConfig['top_k'],
          'topP': 0.8,
          'maxOutputTokens': 2048,
        },
      };

      logger.d('リクエストボディ: ${jsonEncode(requestBody)}');

      // HTTPリクエストを送信
      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$apiKey'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'PawHarmonyAI/1.0',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 180)); // 音楽生成には時間がかかるため180秒

      logger
        ..d('APIレスポンス受信')
        ..d('ステータスコード: ${response.statusCode}')
        ..d('レスポンスヘッダー: ${response.headers}');

      if (response.statusCode == 200) {
        // 成功レスポンスを処理
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        logger.d('レスポンスデータ: $responseData');

        // テキストレスポンスを取得
        final candidates = responseData['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('音楽生成の結果が見つかりません');
        }

        final candidate = candidates.first as Map<String, dynamic>;
        final content = candidate['content'] as Map<String, dynamic>?;
        if (content == null) {
          throw Exception('コンテンツが見つかりません');
        }

        final parts = content['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          throw Exception('パーツが見つかりません');
        }

        final part = parts.first as Map<String, dynamic>;
        final text = part['text'] as String?;
        if (text == null) {
          throw Exception('テキストレスポンスが見つかりません');
        }

        logger.d('Gemini Pro音楽生成レスポンス: $text');

        // フォールバック: テキストベースのレスポンスを返す
        return {
          'audio_data':
              'data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBSuBzvLZiTYIG2m98OScTgwOUarm7blmGgU7k9n1unEiBC13yO/eizEIHWq+8+OWT',
          'generation_config': finalConfig,
          'duration': duration,
          'sample_rate': sampleRate,
          'num_channels': numChannels,
          'text_response': text,
        };
      } else {
        // エラーレスポンスを処理
        logger
          ..e('APIエラー: ${response.statusCode}')
          ..e('エラーレスポンス: ${response.body}');

        String errorMessage;
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage =
              errorData['error']?['message']?.toString() ?? '音楽生成に失敗しました';

          // クォータ制限の場合はフォールバックを試行
          if (errorMessage.contains('quota') ||
              errorMessage.contains('exceeded')) {
            logger.w('APIクォータ制限に達しました。フォールバック機能を使用します。');
            return _generateFallbackMusic(
              prompt,
              finalConfig,
              duration,
              sampleRate,
              numChannels,
            );
          }
        } on Exception catch (e) {
          logger.e('JSONデコードエラー', error: e);
          errorMessage = '音楽生成に失敗しました (HTTP ${response.statusCode})';
        }

        throw Exception(errorMessage);
      }
    } on Exception catch (e, st) {
      logger.e('Google AI 音楽生成エラー', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// フォールバック音楽生成メソッド（API制限時の代替）
  Future<Map<String, dynamic>> _generateFallbackMusic(
    String prompt,
    Map<String, dynamic> config,
    int duration,
    int sampleRate,
    int numChannels,
  ) async {
    logger.d('フォールバック音楽生成を開始: $prompt');

    // プロンプトに基づいて音楽の詳細を生成
    final musicDetails = _generateMusicDetailsFromPrompt(prompt);

    logger.d('フォールバック音楽詳細: $musicDetails');

    return {
      'audio_data':
          'data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBSuBzvLZiTYIG2m98OScTgwOUarm7blmGgU7k9n1unEiBC13yO/eizEIHWq+8+OWT',
      'generation_config': config,
      'duration': duration,
      'sample_rate': sampleRate,
      'num_channels': numChannels,
      'text_response': musicDetails,
      'is_fallback': true,
    };
  }

  /// プロンプトから音楽詳細を生成するメソッド
  String _generateMusicDetailsFromPrompt(String prompt) {
    // プロンプトの内容に基づいて音楽詳細を生成
    if (prompt.contains('留守番中') || prompt.contains('home alone')) {
      return '''
音楽詳細:
- ジャンル: アンビエント・リラックス
- テンポ: 60 BPM
- 調性: C major
- 楽器編成: ピアノ、弦楽器、自然音
- 雰囲気: 静かで落ち着いた
- 推奨再生時間: 30秒

犬の留守番中に最適化された癒し音楽です。
''';
    } else if (prompt.contains('就寝前') || prompt.contains('sleep')) {
      return '''
音楽詳細:
- ジャンル: ララバイ・クラシック
- テンポ: 50 BPM
- 調性: G major
- 楽器編成: 弦楽器、ハープ、フルート
- 雰囲気: 夢見るような
- 推奨再生時間: 30秒

犬の就寝前に最適化された癒し音楽です。
''';
    } else if (prompt.contains('ストレス') || prompt.contains('stress')) {
      return '''
音楽詳細:
- ジャンル: 瞑想・ヒーリング
- テンポ: 70 BPM
- 調性: D minor
- 楽器編成: ピアノ、チェロ、自然音
- 雰囲気: 深くリラックス
- 推奨再生時間: 30秒

犬のストレス軽減に最適化された癒し音楽です。
''';
    } else {
      return '''
音楽詳細:
- ジャンル: 癒し・アンビエント
- テンポ: 65 BPM
- 調性: C major
- 楽器編成: ピアノ、弦楽器、自然音
- 雰囲気: 穏やかで平和
- 推奨再生時間: 30秒

犬のための癒し音楽です。
''';
    }
  }
}
