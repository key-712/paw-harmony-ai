import 'dart:convert';
import 'dart:math';

import 'package:logger/logger.dart';

import 'base_music_service.dart';

/// Web Audio APIを使用した音楽生成サービス
class WebAudioMusicService extends BaseMusicService {
  /// WebAudioMusicServiceのコンストラクタ
  WebAudioMusicService({Logger? logger}) : logger = logger ?? Logger();

  /// ロガー
  final Logger logger;

  /// APIキーが有効かどうかを確認するメソッド（Web Audio APIはAPIキー不要）
  @override
  bool get isApiKeyValid => true;

  /// 音楽を生成するメソッド
  ///
  /// [prompt] 音楽生成のプロンプト
  /// [duration] 音楽の長さ（秒）
  /// [config] 生成設定
  @override
  Future<Map<String, dynamic>> generateMusic({
    required String prompt,
    int duration = 30,
    Map<String, dynamic>? config,
  }) async {
    logger
      ..d('=== Web Audio API 音楽生成開始 ===')
      ..d('プロンプト: $prompt')
      ..d('長さ: $duration秒');

    try {
      // デフォルト設定
      final defaultConfig = {
        'bpm': 60,
        'key': 'C',
        'mode': 'major',
        'instruments': ['piano', 'strings'],
        'volume': 0.7,
        'reverb': 0.3,
      };

      // カスタム設定があればマージ
      final finalConfig = {...defaultConfig, ...?config};

      // プロンプトから音楽パラメータを解析
      final musicParams = _parsePromptToMusicParams(prompt, finalConfig);

      // Web Audio APIで音楽を生成
      final audioData = await _generateWebAudioMusic(
        duration: duration,
        params: musicParams,
        config: finalConfig,
      );

      return {
        'audio_data': audioData,
        'generation_config': finalConfig,
        'duration': duration,
        'music_params': musicParams,
        'service_type': 'web_audio',
        'service_name': 'Web Audio API',
      };
    } on Exception catch (e, st) {
      logger.e('Web Audio API音楽生成エラー', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// プロンプトから音楽パラメータを解析するメソッド
  Map<String, dynamic> _parsePromptToMusicParams(
    String prompt,
    Map<String, dynamic> config,
  ) {
    final params = <String, dynamic>{};

    // 基本パラメータ
    params['bpm'] = config['bpm'] ?? 60;
    params['key'] = config['key'] ?? 'C';
    params['mode'] = config['mode'] ?? 'major';
    params['volume'] = config['volume'] ?? 0.7;

    // プロンプトから感情を解析
    if (prompt.contains('calm') || prompt.contains('peaceful')) {
      params['bpm'] = 50;
      params['mode'] = 'major';
      params['instruments'] = ['piano', 'strings', 'pad'];
    } else if (prompt.contains('relaxing')) {
      params['bpm'] = 60;
      params['mode'] = 'major';
      params['instruments'] = ['piano', 'flute', 'strings'];
    } else if (prompt.contains('sleep')) {
      params['bpm'] = 40;
      params['mode'] = 'minor';
      params['instruments'] = ['piano', 'harp', 'pad'];
    } else {
      params['instruments'] = config['instruments'] ?? ['piano', 'strings'];
    }

    // 犬種に基づく調整
    if (prompt.contains('small') || prompt.contains('チワワ')) {
      params['volume'] = 0.5;
      params['bpm'] = (params['bpm'] as int) + 10;
    } else if (prompt.contains('large') || prompt.contains('ゴールデン')) {
      params['volume'] = 0.8;
      params['bpm'] = (params['bpm'] as int) - 10;
    }

    return params;
  }

  /// Web Audio APIで音楽を生成するメソッド
  Future<String> _generateWebAudioMusic({
    required int duration,
    required Map<String, dynamic> params,
    required Map<String, dynamic> config,
  }) async {
    logger.d('Web Audio APIで音楽生成中...');

    // 簡易的な音楽データを生成（実際のWeb Audio APIの実装は複雑）
    const sampleRate = 44100;
    final numSamples = duration * sampleRate;
    final audioData = <int>[];

    // 基本周波数（C4 = 261.63 Hz）
    const baseFreq = 261.63;
    final bpm = params['bpm'] as int;
    final beatsPerSecond = bpm / 60.0;

    // 音楽データを生成
    for (var i = 0; i < numSamples; i++) {
      final time = i / sampleRate;
      final beat = time * beatsPerSecond;

      // メロディーラインを生成
      final melody = _generateMelodyNote(beat, baseFreq, params);

      // ハーモニーを生成
      final harmony = _generateHarmonyNote(beat, baseFreq, params);

      // 音量エンベロープを適用
      final envelope = _applyEnvelope(time, duration);

      // 最終的な音声サンプルを計算
      final sample =
          ((melody + harmony) * envelope * (params['volume'] as double))
              .round();

      // 16ビットPCMに変換
      final pcmSample = sample.clamp(-32768, 32767);
      audioData.add(pcmSample);
    }

    // WAVファイルヘッダーを生成
    final wavHeader = _generateWavHeader(
      audioData.length,
      sampleRate,
      1, // モノラル
    );

    // データを結合
    final allData = <int>[...wavHeader, ...audioData];

    // Base64エンコード
    final bytes = allData.map((b) => b.toSigned(8)).toList();
    final base64Data = base64Encode(bytes);

    return 'data:audio/wav;base64,$base64Data';
  }

  /// メロディーノートを生成するメソッド
  double _generateMelodyNote(
    double beat,
    double baseFreq,
    Map<String, dynamic> params,
  ) {
    final scale = _getScale(params['key'] as String, params['mode'] as String);
    final noteIndex = (beat * 2).floor() % scale.length;
    final frequency = baseFreq * scale[noteIndex];

    return _generateSineWave(beat, frequency);
  }

  /// ハーモニーノートを生成するメソッド
  double _generateHarmonyNote(
    double beat,
    double baseFreq,
    Map<String, dynamic> params,
  ) {
    final scale = _getScale(params['key'] as String, params['mode'] as String);
    final noteIndex = (beat * 4).floor() % scale.length;
    final frequency = baseFreq * scale[noteIndex] * 2; // オクターブ上

    return _generateSineWave(beat, frequency) * 0.3;
  }

  /// サイン波を生成するメソッド
  double _generateSineWave(double time, double frequency) {
    return sin(2 * pi * frequency * time);
  }

  /// スケールを取得するメソッド
  List<double> _getScale(String key, String mode) {
    if (mode == 'major') {
      return [1.0, 1.125, 1.25, 1.333, 1.5, 1.667, 1.875, 2.0];
    } else {
      return [1.0, 1.125, 1.25, 1.333, 1.5, 1.6, 1.875, 2.0];
    }
  }

  /// エンベロープを適用するメソッド
  double _applyEnvelope(double time, int duration) {
    const attack = 0.1;
    const decay = 0.1;
    const sustain = 0.7;
    const release = 0.2;

    if (time < attack) {
      return time / attack;
    } else if (time < attack + decay) {
      return 1.0 - (time - attack) / decay * (1.0 - sustain);
    } else if (time < duration - release) {
      return sustain;
    } else {
      return sustain * (1.0 - (time - (duration - release)) / release);
    }
  }

  /// WAVファイルヘッダーを生成するメソッド
  List<int> _generateWavHeader(int dataLength, int sampleRate, int channels) {
    final header = <int>[
      ...'RIFF'.codeUnits,
      ..._intToBytes(36 + dataLength * 2, 4),
      ...'WAVE'.codeUnits,
      ...'fmt '.codeUnits,
      ..._intToBytes(16, 4),
      ..._intToBytes(1, 2),
      ..._intToBytes(channels, 2),
      ..._intToBytes(sampleRate, 4),
      ..._intToBytes(sampleRate * channels * 2, 4),
      ..._intToBytes(channels * 2, 2),
      ..._intToBytes(16, 2),
      ...'data'.codeUnits,
      ..._intToBytes(dataLength * 2, 4),
    ]
    // RIFFヘッダー
    // ファイルサイズ
    // fmt チャンク
    // fmt チャンクサイズ
    // PCM
    // チャンネル数
    // サンプリングレート
    // バイトレート
    // ブロックサイズ
    // ビット深度
    // data チャンク
    ; // データサイズ

    return header;
  }

  /// 整数をバイト配列に変換するメソッド
  List<int> _intToBytes(int value, int length) {
    final bytes = <int>[];
    for (var i = 0; i < length; i++) {
      bytes.add((value >> (i * 8)) & 0xFF);
    }
    return bytes;
  }
}
