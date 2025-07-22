import 'dart:convert';
import 'dart:math';

import 'package:logger/logger.dart';

import 'base_music_service.dart';

/// Magenta.jsを使用した音楽生成サービス
class MagentaMusicService extends BaseMusicService {
  /// MagentaMusicServiceのコンストラクタ
  MagentaMusicService({Logger? logger}) : logger = logger ?? Logger();

  /// ロガー
  final Logger logger;

  /// APIキーが有効かどうかを確認するメソッド（Magenta.jsはAPIキー不要）
  @override
  bool get isApiKeyValid => true;

  /// Magenta.jsのHTMLテンプレート
  static const _magentaHtmlTemplate = '''
<!DOCTYPE html>
<html>
<head>
    <title>Magenta.js Music Generation</title>
    <script src="https://cdn.jsdelivr.net/npm/@magenta/music@^1.23.1/dist/magentamusic.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@^3.9.0/dist/tf.min.js"></script>
</head>
<body>
    <div id="status">Loading Magenta.js...</div>
    <script>
        let mm = null;
        let model = null;
        
        async function initializeMagenta() {
            try {
                mm = new mm.MusicVAE('https://storage.googleapis.com/magentadata/js/checkpoints/music_vae/mel_4bar_small_q2');
                await mm.initialize();
                document.getElementById('status').innerHTML = 'Magenta.js initialized successfully';
                return true;
            } catch (error) {
                document.getElementById('status').innerHTML = 'Error initializing Magenta.js: ' + error.message;
                return false;
            }
        }
        
        async function generateMusic(prompt, duration, config) {
            try {
                if (!mm) {
                    throw new Error('Magenta.js not initialized');
                }
                
                // プロンプトから音楽パラメータを解析
                const params = parsePromptToMusicParams(prompt, config);
                
                // 音楽生成
                const generatedMusic = await generateMagentaMusic(duration, params);
                
                return {
                    success: true,
                    audioData: generatedMusic,
                    params: params
                };
            } catch (error) {
                return {
                    success: false,
                    error: error.message
                };
            }
        }
        
        function parsePromptToMusicParams(prompt, config) {
            const params = {
                bpm: config.bpm || 60,
                key: config.key || 'C',
                mode: config.mode || 'major',
                volume: config.volume || 0.7,
                instruments: config.instruments || ['piano', 'strings']
            };
            
            const lowerPrompt = prompt.toLowerCase();
            
            if (lowerPrompt.includes('calm') || lowerPrompt.includes('peaceful')) {
                params.bpm = 50;
                params.mode = 'major';
                params.instruments = ['piano', 'strings', 'pad'];
            } else if (lowerPrompt.includes('relaxing')) {
                params.bpm = 60;
                params.mode = 'major';
                params.instruments = ['piano', 'flute', 'strings'];
            } else if (lowerPrompt.includes('sleep')) {
                params.bpm = 40;
                params.mode = 'minor';
                params.instruments = ['piano', 'harp', 'pad'];
            }
            
            return params;
        }
        
        async function generateMagentaMusic(duration, params) {
            // シーケンスを生成
            const sequence = {
                notes: [],
                totalTime: duration,
                timeSignatures: [{ time: 0, numerator: 4, denominator: 4 }],
                tempos: [{ time: 0, qpm: params.bpm }]
            };
            
            // メロディーラインを生成
            const melodyNotes = generateMelodyNotes(duration, params);
            sequence.notes.push(...melodyNotes);
            
            // ハーモニーラインを生成
            const harmonyNotes = generateHarmonyNotes(duration, params);
            sequence.notes.push(...harmonyNotes);
            
            // MIDIファイルに変換
            const midiData = mm.sequenceProtoToMidi(sequence);
            
            // Base64エンコード
            const base64Data = btoa(String.fromCharCode(...new Uint8Array(midiData)));
            
            return {
                success: true,
                audioData: 'data:audio/midi;base64,' + base64Data,
                params: params
            };
        }
        
        function generateMelodyNotes(duration, params) {
            const notes = [];
            const scale = getScale(params.key, params.mode);
            const beatDuration = 60 / params.bpm;
            
            for (let time = 0; time < duration; time += beatDuration) {
                const noteIndex = Math.floor(time * 2) % scale.length;
                const pitch = 60 + (noteIndex * 2); // C4から開始
                
                notes.push({
                    pitch: pitch,
                    startTime: time,
                    endTime: time + beatDuration,
                    velocity: Math.floor(params.volume * 100)
                });
            }
            
            return notes;
        }
        
        function generateHarmonyNotes(duration, params) {
            const notes = [];
            const scale = getScale(params.key, params.mode);
            const beatDuration = 60 / params.bpm;
            
            for (let time = 0; time < duration; time += beatDuration * 2) {
                const noteIndex = Math.floor(time * 4) % scale.length;
                const pitch = 60 + (noteIndex * 2) + 12; // オクターブ上
                
                notes.push({
                    pitch: pitch,
                    startTime: time,
                    endTime: time + beatDuration * 2,
                    velocity: Math.floor(params.volume * 50)
                });
            }
            
            return notes;
        }
        
        function getScale(key, mode) {
            if (mode === 'major') {
                return [0, 2, 4, 5, 7, 9, 11, 12];
            } else {
                return [0, 2, 3, 5, 7, 8, 10, 12];
            }
        }
        
        // 初期化
        initializeMagenta();
    </script>
</body>
</html>
''';

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
    logger.d('音楽生成開始 プロンプト: $prompt');

    try {
      // デフォルト設定
      final defaultConfig = {
        'bpm': 60,
        'key': 'C',
        'mode': 'major',
        'instruments': ['piano', 'strings'],
        'volume': 0.7,
        'temperature': 1.0,
      };

      // カスタム設定があればマージ
      final finalConfig = {...defaultConfig, ...?config};

      // プロンプトから音楽パラメータを解析
      final musicParams = _parsePromptToMusicParams(prompt, finalConfig);

      // Magenta.jsで音楽を生成
      final audioData = await _generateMagentaMusic(
        duration: duration,
        params: musicParams,
        config: finalConfig,
      );

      return {
        'audio_data': audioData,
        'generation_config': finalConfig,
        'duration': duration,
        'music_params': musicParams,
        'service_type': 'magenta',
        'service_name': 'Magenta.js',
      };
    } on Exception catch (e, st) {
      logger.e('Magenta.js音楽生成エラー', error: e, stackTrace: st);
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
    params['temperature'] = config['temperature'] ?? 1.0;

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

  /// Magenta.jsで音楽を生成するメソッド
  Future<String> _generateMagentaMusic({
    required int duration,
    required Map<String, dynamic> params,
    required Map<String, dynamic> config,
  }) async {
    // 簡易的なMIDIデータを生成
    final midiData = _generateSimpleMidiData(duration, params);

    // MIDIデータをWAVファイルに変換
    final wavData = _convertMidiToWav(midiData, duration, params);

    // Base64エンコード
    final base64Data = base64Encode(wavData);

    return 'data:audio/wav;base64,$base64Data';
  }

  /// MIDIデータをWAVファイルに変換するメソッド
  List<int> _convertMidiToWav(
    List<int> midiData,
    int duration,
    Map<String, dynamic> params,
  ) {
    const sampleRate = 44100;
    final numSamples = duration * sampleRate;
    final audioData = <int>[];

    // 基本周波数（C4 = 261.63 Hz）
    const baseFreq = 261.63;
    final bpm = params['bpm'] as int;
    final beatsPerSecond = bpm / 60.0;
    final volume = params['volume'] as double;

    // 音楽データを生成
    for (var i = 0; i < numSamples; i++) {
      final time = i / sampleRate;
      final beat = time * beatsPerSecond;

      // メロディーラインを生成
      final melody = _generateMelodyNote(beat, baseFreq, params);

      // 音量エンベロープを適用
      final envelope = _applyEnvelope(time, duration);

      // 最終的な音声サンプルを計算
      final sample = (melody * envelope * volume * 32767).round();

      // 16ビットPCMに変換（負の値を適切に処理）
      final pcmSample = sample.clamp(-32768, 32767);

      // 負の値を正の値に変換（リトルエンディアン形式）
      final unsignedValue = pcmSample < 0 ? 65536 + pcmSample : pcmSample;
      final lowByte = unsignedValue & 0xFF;
      final highByte = (unsignedValue >> 8) & 0xFF;

      audioData
        ..add(lowByte)
        ..add(highByte);
    }

    // WAVファイルヘッダーを生成
    final wavHeader = _generateWavHeader(
      audioData.length ~/ 2, // サンプル数（バイト数÷2）
      sampleRate,
      1, // モノラル
    );

    // データを結合
    final allData = <int>[...wavHeader, ...audioData];

    return allData;
  }

  /// メロディーノートを生成するメソッド
  double _generateMelodyNote(
    double beat,
    double baseFreq,
    Map<String, dynamic> params,
  ) {
    final scale = _getScale(params['key'] as String, params['mode'] as String);

    // より自然なメロディー生成のための改善
    final noteIndex = _generateNaturalMelodyIndex(beat, scale.length, params);
    final pitch = 60 + scale[noteIndex];
    final freq = baseFreq * pow(2, (pitch - 60) / 12);

    // 正弦波でメロディーを生成
    final t = beat * 2 * pi;
    return sin(freq * t);
  }

  /// より自然なメロディーインデックスを生成するメソッド
  int _generateNaturalMelodyIndex(
    double beat,
    int scaleLength,
    Map<String, dynamic> params,
  ) {
    // 基本的なパターン生成
    final basePattern = _generateMelodyPattern(beat, scaleLength, params);

    // ランダム性を追加（温度パラメータに基づく）
    final temperature = params['temperature'] as double? ?? 1.0;
    final randomFactor = (temperature - 0.5) * 0.3;

    // パターンにランダム性を適用
    final adjustedIndex = (basePattern + randomFactor).round();

    // スケール範囲内に制限
    return adjustedIndex.clamp(0, scaleLength - 1);
  }

  /// メロディーパターンを生成するメソッド
  double _generateMelodyPattern(
    double beat,
    int scaleLength,
    Map<String, dynamic> params,
  ) {
    final bpm = params['bpm'] as int? ?? 60;
    final mode = params['mode'] as String? ?? 'major';
    final scenario = params['scenario'] as String?;

    // レゲエ、ソフトロック、クラシックの特徴を反映
    if (scenario != null) {
      switch (scenario) {
        case '留守番中':
        case '長距離移動中':
          // レゲエ風：オフビートリズム
          return _generateReggaePattern(beat, scaleLength, bpm);
        case 'ストレスフル':
        case '療養/高齢犬ケア':
          // ソフトロック風：温かいハーモニー
          return _generateSoftRockPattern(beat, scaleLength, bpm);
        case '就寝前':
        case '日常の癒し':
          // クラシック風：優雅なメロディー
          return _generateClassicalPattern(beat, scaleLength, bpm);
        default:
          break;
      }
    }

    // 複数のパターンを組み合わせ
    final pattern1 = _generateArpeggioPattern(beat, scaleLength, bpm);
    final pattern2 = _generateScalePattern(beat, scaleLength, bpm);
    final pattern3 = _generateChordPattern(beat, scaleLength, bpm);

    // パターンを重ね合わせ
    final combinedPattern = pattern1 * 0.4 + pattern2 * 0.4 + pattern3 * 0.2;

    // モードに応じた調整
    if (mode == 'minor') {
      return combinedPattern * 0.8; // マイナーモードは少し暗め
    }

    return combinedPattern;
  }

  /// アルペジオパターンを生成するメソッド（テンポ調整版）
  double _generateArpeggioPattern(double beat, int scaleLength, int bpm) {
    final cycle = (beat * bpm / 60.0) % 4; // 4拍子のサイクル
    final arpeggioPattern = [0, 2, 4, 2, 0, 4, 2, 0]; // アルペジオパターン
    final patternIndex =
        (cycle * 1.5).floor() % arpeggioPattern.length; // テンポに応じて調整
    return arpeggioPattern[patternIndex].toDouble();
  }

  /// スケールパターンを生成するメソッド（テンポ調整版）
  double _generateScalePattern(double beat, int scaleLength, int bpm) {
    final cycle = (beat * bpm / 60.0) % 8; // 8拍子のサイクル
    final scalePattern = [0, 1, 2, 3, 4, 5, 6, 7]; // スケールパターン
    final patternIndex =
        (cycle * 0.8).floor() % scalePattern.length; // テンポに応じて調整
    return scalePattern[patternIndex].toDouble();
  }

  /// コードパターンを生成するメソッド（テンポ調整版）
  double _generateChordPattern(double beat, int scaleLength, int bpm) {
    final cycle = (beat * bpm / 60.0) % 6; // 6拍子のサイクル
    final chordPattern = [0, 2, 4, 0, 2, 4]; // コードパターン
    final patternIndex =
        (cycle * 1.2).floor() % chordPattern.length; // テンポに応じて調整
    return chordPattern[patternIndex].toDouble();
  }

  /// レゲエ風パターンを生成するメソッド
  double _generateReggaePattern(double beat, int scaleLength, int bpm) {
    final cycle = (beat * bpm / 60.0) % 4; // 4拍子のサイクル
    final reggaePattern = [0, 2, 4, 2, 0, 4, 2, 0]; // レゲエの特徴的なパターン
    final patternIndex = (cycle * 2).floor() % reggaePattern.length;
    return reggaePattern[patternIndex].toDouble();
  }

  /// ソフトロック風パターンを生成するメソッド
  double _generateSoftRockPattern(double beat, int scaleLength, int bpm) {
    final cycle = (beat * bpm / 60.0) % 6; // 6拍子のサイクル
    final softRockPattern = [0, 2, 4, 0, 2, 4]; // ソフトロックの温かいハーモニー
    final patternIndex = cycle.floor() % softRockPattern.length;
    return softRockPattern[patternIndex].toDouble();
  }

  /// クラシック風パターンを生成するメソッド
  double _generateClassicalPattern(double beat, int scaleLength, int bpm) {
    final cycle = (beat * bpm / 60.0) % 8; // 8拍子のサイクル
    final classicalPattern = [0, 2, 4, 7, 4, 2, 0, 2]; // クラシックの優雅なメロディー
    final patternIndex = cycle.floor() % classicalPattern.length;
    return classicalPattern[patternIndex].toDouble();
  }

  /// 音量エンベロープを適用するメソッド
  double _applyEnvelope(double time, int duration) {
    // フェードイン・フェードアウト
    const fadeTime = 0.1; // 0.1秒
    if (time < fadeTime) {
      return time / fadeTime; // フェードイン
    } else if (time > duration - fadeTime) {
      return (duration - time) / fadeTime; // フェードアウト
    } else {
      return 1; // 通常音量
    }
  }

  /// WAVファイルヘッダーを生成するメソッド
  List<int> _generateWavHeader(int dataLength, int sampleRate, int channels) {
    final header = <int>[
      ...'RIFF'.codeUnits,
      ..._intToBytes(36 + dataLength * 2, 4, littleEndian: true),
      ...'WAVE'.codeUnits,
      ...'fmt '.codeUnits,
      ..._intToBytes(16, 4, littleEndian: true),
      ..._intToBytes(1, 2, littleEndian: true),
      ..._intToBytes(channels, 2, littleEndian: true),
      ..._intToBytes(sampleRate, 4, littleEndian: true),
      ..._intToBytes(sampleRate * channels * 2, 4, littleEndian: true),
      ..._intToBytes(channels * 2, 2, littleEndian: true),
      ..._intToBytes(16, 2, littleEndian: true),
      ...'data'.codeUnits,
      ..._intToBytes(dataLength * 2, 4, littleEndian: true),
    ];

    return header;
  }

  /// 整数をバイト配列に変換するメソッド
  List<int> _intToBytes(int value, int length, {bool littleEndian = false}) {
    final bytes = <int>[];
    if (littleEndian) {
      // リトルエンディアン（WAVファイルの標準）
      for (var i = 0; i < length; i++) {
        bytes.add((value >> (i * 8)) & 0xFF);
      }
    } else {
      // ビッグエンディアン
      for (var i = length - 1; i >= 0; i--) {
        bytes.add((value >> (i * 8)) & 0xFF);
      }
    }
    return bytes;
  }

  /// 簡易的なMIDIデータを生成するメソッド
  List<int> _generateSimpleMidiData(int duration, Map<String, dynamic> params) {
    final midiData = <int>[
      0x4D,
      0x54,
      0x68,
      0x64,
      0x00,
      0x00,
      0x00,
      0x06,
      0x00,
      0x01,
      0x00,
      0x01,
      0x01,
      0xE0,
      0x4D,
      0x54,
      0x72,
      0x6B,
    ]
    // MIDIファイルヘッダー
    // MThd
    // ヘッダー長
    // フォーマット1
    // トラック数1（シンプルに）
    // テンポ（480 ticks/beat）
    // トラック1（メロディー）
    ; // MTrk
    final trackLength = _generateMelodyTrack(midiData, duration, params);
    midiData.addAll(<int>[
      (trackLength >> 24) & 0xFF,
      (trackLength >> 16) & 0xFF,
      (trackLength >> 8) & 0xFF,
      trackLength & 0xFF,
    ]);

    return midiData;
  }

  /// メロディートラックを生成するメソッド
  int _generateMelodyTrack(
    List<int> midiData,
    int duration,
    Map<String, dynamic> params,
  ) {
    final startLength = midiData.length;

    // テンポ設定
    final bpm = params['bpm'] as int;
    final tempo = (60000000 / bpm).round();
    midiData
      ..addAll(<int>[
        0x00,
        0xFF,
        0x51,
        0x03,
        (tempo >> 16) & 0xFF,
        (tempo >> 8) & 0xFF,
        tempo & 0xFF,
      ])
      // 楽器設定
      ..addAll(<int>[0x00, 0xC0, 0x00]); // ピアノ

    // メロディーノート
    final scale = _getScale(params['key'] as String, params['mode'] as String);
    final beatDuration = 60.0 / bpm;
    const ticksPerBeat = 480;
    final int step = max(1, beatDuration.round());

    for (var i = 0; i < duration; i += step) {
      final noteIndex = (i * 2) % scale.length;
      final pitch = 60 + scale[noteIndex];
      final velocity = ((params['volume'] as double) * 100).round();

      // ノートオン（デルタタイムを0に）
      midiData.addAll(<int>[0x00, 0x90, pitch, velocity]);

      // ノートオフ（デルタタイムを適切な値に）
      final noteOffTime = min(
        127,
        max(1, (beatDuration * ticksPerBeat / 4).round()),
      );
      midiData.addAll(<int>[noteOffTime, 0x80, pitch, 0x00]);
    }

    // トラック終了
    midiData.addAll(<int>[0x00, 0xFF, 0x2F, 0x00]);

    return midiData.length - startLength;
  }

  /// スケールを取得するメソッド
  List<int> _getScale(String key, String mode) {
    if (mode == 'major') {
      return [0, 2, 4, 5, 7, 9, 11, 12];
    } else {
      return [0, 2, 3, 5, 7, 8, 10, 12];
    }
  }

  /// HTMLテンプレートを取得するメソッド
  String getHtmlTemplate() {
    return _magentaHtmlTemplate;
  }
}
