// PlayerStateをfreezedで定義
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../import/model.dart';
import '../import/utility.dart';

part 'music_player_state_notifier.freezed.dart';

/// 音楽プレイヤーの状態を表すモデルクラス
@freezed
class PlayerState with _$PlayerState {
  /// PlayerStateを作成するファクトリーメソッド
  const factory PlayerState({
    @Default(false) bool isPlaying,
    @Default(Duration.zero) Duration position,
    Duration? duration,
    Duration? timerDuration,
    @Default(null) AppError? appError,
  }) = _PlayerState;

  const PlayerState._();
}

/// 音楽プレイヤーの状態を管理するStateNotifier
class MusicPlayerStateNotifier extends StateNotifier<PlayerState> {
  /// MusicPlayerStateNotifierのコンストラクタ
  MusicPlayerStateNotifier()
    : _audioPlayer = AudioPlayer(),
      super(const PlayerState()) {
    _initializeAudioPlayer();
  }

  /// オーディオプレイヤーの初期化
  void _initializeAudioPlayer() {
    try {
      logger.d('=== オーディオプレイヤー初期化開始 ===');

      _audioPlayer.positionStream.listen((position) {
        logger.d('再生位置更新: $position');
        state = state.copyWith(position: position);
      });

      _audioPlayer.durationStream.listen((duration) {
        logger.d('総再生時間更新: $duration');
        state = state.copyWith(duration: duration);
      });

      _audioPlayer.playingStream.listen((isPlaying) {
        logger.d('再生状態変更: ${isPlaying ? "再生中" : "停止中"}');
        state = state.copyWith(isPlaying: isPlaying);
      });

      // プレイヤー状態の監視（自動再生なし）
      _audioPlayer.playerStateStream.listen((playerState) {
        logger.d('プレイヤー状態: ${playerState.processingState}');
        if (playerState.processingState == ProcessingState.idle) {
          logger.w('プレイヤーがアイドル状態です');
        }
      });

      // エラーストリームの監視を追加
      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.idle) {
          logger.w('プレイヤーがアイドル状態です');
        }
      });

      logger.d('オーディオプレイヤー初期化完了');
    } on PlayerException catch (e) {
      logger.e('Player exception: $e');
    } on Exception catch (e) {
      logger.e('Failed to initialize audio player: $e');
    }
  }

  /// オーディオプレイヤーのインスタンス
  final AudioPlayer _audioPlayer;

  /// 音楽URLを設定するメソッド
  ///
  /// [url] 再生する音楽のURL
  Future<void> setUrl(String url, BuildContext context) async {
    try {
      // URLの形式をログ出力
      logger.d('Setting URL: $url');

      // URLの妥当性をチェック
      if (url.isEmpty) {
        throw Exception('URL is empty');
      }

      // Firebase Storage URLの場合、ファイルをダウンロードしてから再生
      if (url.contains('firebase') && !url.contains('data:audio')) {
        logger.d('Firebase Storage URL detected, downloading file...');
        try {
          final localFile = await _downloadAndSaveFile(url);
          logger.d('File downloaded to: ${localFile.path}');

          // ファイルの詳細情報をログ出力
          final fileSize = await localFile.length();
          logger.d('Downloaded file size: $fileSize bytes');

          // ファイルの存在確認
          if (!await localFile.exists()) {
            throw Exception('Downloaded file does not exist');
          }

          // iOSでの再生互換性を向上させるための処理
          logger.d(
            'Setting file path for iOS compatibility: ${localFile.path}',
          );
          await _audioPlayer.setFilePath(localFile.path);
          logger.d('Local file set successfully for iOS');
          return;
        } on Exception catch (e) {
          logger.e('Failed to download or set local file: $e');
        }
      }

      // Firebase Storage URLの場合、Base64データとして直接再生を試行
      if (url.contains('firebase') && url.contains('data:audio')) {
        logger.d('Attempting to play Base64 audio data...');
        try {
          // Base64データを抽出
          final dataIndex = url.indexOf(',');
          if (dataIndex != -1) {
            final base64Data = url.substring(dataIndex + 1);
            logger.d('Base64 data length: ${base64Data.length}');

            // Base64データをデコードして一時ファイルに保存
            final bytes = base64Decode(base64Data);
            final tempDir = await getTemporaryDirectory();
            final fileName =
                'music_base64_${DateTime.now().millisecondsSinceEpoch}.wav';
            final file = File('${tempDir.path}/$fileName');

            await file.writeAsBytes(bytes);
            logger.d('Base64 file saved to: ${file.path}');

            await _audioPlayer.setFilePath(file.path);
            logger.d('Base64 file set successfully');
            return;
          }
        } on Exception catch (e) {
          logger.e('Failed to play Base64 data: $e');
        }
      }

      // Firebase Storage URLの場合、適切な形式に変換
      var processedUrl = url;
      if (url.contains('firebase')) {
        // Firebase Storage URLの場合、アクセストークンを追加
        if (!url.contains('token=')) {
          processedUrl = '$url?alt=media';
        }

        // URLエンコーディングの問題を解決
        processedUrl = Uri.parse(processedUrl).toString();
        logger.d('Firebase URL processed: $processedUrl');
      }

      logger.d('Processed URL: $processedUrl');

      // 最適化されたWAVファイルの処理
      if (processedUrl.contains('.wav')) {
        logger.d('Optimized WAV file detected. Should work on iOS.');
      } else if (processedUrl.contains('.mp3')) {
        logger.d('MP3 file detected. Better iOS compatibility.');
      }

      // より詳細なエラーハンドリングでURL設定を試行
      try {
        await _audioPlayer.setUrl(processedUrl);
        logger.d('URL set successfully');
      } on PlayerException catch (e) {
        logger.e('Player exception during setUrl: $e');

        // 代替方法を試行：URLを再エンコード
        try {
          final reencodedUrl = Uri.encodeFull(processedUrl);
          logger.d('Trying reencoded URL: $reencodedUrl');
          await _audioPlayer.setUrl(reencodedUrl);
          logger.d('Reencoded URL set successfully');
        } on PlayerException catch (e2) {
          logger.e('Player exception with reencoded URL: $e2');
          rethrow; // 元のエラーを再スロー
        }
      }
    } on PlayerException catch (e) {
      logger.e('Player exception: $e');
      if (!context.mounted) return;
      state = state.copyWith(appError: AppError(error: e, context: context));
    } on Exception catch (e) {
      logger.e('General exception: $e');
      if (!context.mounted) return;
      state = state.copyWith(appError: AppError(error: e, context: context));
    }
  }

  /// Firebase Storageからファイルをダウンロードして保存するメソッド
  Future<File> _downloadAndSaveFile(String url) async {
    try {
      logger.d('Downloading file from: $url');

      // HTTPリクエストを送信（タイムアウトを設定）
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'PawHarmonyAI/1.0',
              'Accept': 'audio/wav, audio/*, */*',
            },
          )
          .timeout(const Duration(seconds: 30));

      logger
        ..d('HTTP Response Status: ${response.statusCode}')
        ..d('HTTP Response Headers: ${response.headers}')
        ..d('Response body size: ${response.bodyBytes.length} bytes');

      if (response.statusCode != 200) {
        throw Exception('Failed to download file: HTTP ${response.statusCode}');
      }

      // 一時ディレクトリを取得
      final tempDir = await getTemporaryDirectory();
      logger.d('Temporary directory: ${tempDir.path}');

      final fileName = 'music_${DateTime.now().millisecondsSinceEpoch}.wav';
      final file = File('${tempDir.path}/$fileName');
      logger.d('Target file path: ${file.path}');

      // ファイルに書き込み
      await file.writeAsBytes(response.bodyBytes);
      logger.d(
        'File saved to: ${file.path} (${response.bodyBytes.length} bytes)',
      );

      // ファイルの存在を確認
      if (!await file.exists()) {
        throw Exception('File was not saved properly');
      }

      // ファイルサイズを確認
      final fileSize = await file.length();
      logger.d('Actual file size: $fileSize bytes');

      if (fileSize == 0) {
        throw Exception('Downloaded file is empty');
      }

      // ファイルの先頭バイトを確認（WAVファイルのヘッダー）
      final fileBytes = await file.readAsBytes();
      if (fileBytes.length >= 44) {
        // WAVヘッダーは44バイト
        final header = String.fromCharCodes(fileBytes.take(4));
        final wave = String.fromCharCodes(fileBytes.skip(8).take(4));
        final fmt = String.fromCharCodes(fileBytes.skip(12).take(4));
        final data = String.fromCharCodes(fileBytes.skip(36).take(4));

        logger
          ..d('File header: $header')
          ..d('WAVE identifier: $wave')
          ..d('Format chunk: $fmt')
          ..d('Data chunk: $data');

        if (header != 'RIFF' ||
            wave != 'WAVE' ||
            fmt != 'fmt ' ||
            data != 'data') {
          logger
            ..w('Warning: File does not appear to be a valid WAV file')
            ..w('Expected: RIFF, WAVE, fmt , data')
            ..w('Found: $header, $wave, $fmt, $data');
        } else {
          logger.d('WAV file header appears valid');
        }

        // iOS互換性のための詳細チェック
        if (fileBytes.length >= 24) {
          final sampleRate =
              fileBytes[24] |
              (fileBytes[25] << 8) |
              (fileBytes[26] << 16) |
              (fileBytes[27] << 24);
          logger.d('Sample rate: $sampleRate Hz');

          // チャンネル数を確認
          final channels = fileBytes[22] | (fileBytes[23] << 8);
          logger.d('Channels: $channels');

          // ビット深度を確認
          final bitsPerSample = fileBytes[34] | (fileBytes[35] << 8);
          logger.d('Bits per sample: $bitsPerSample');

          // iOS互換性チェック
          final isIOSCompatible =
              sampleRate == 44100 &&
              (channels == 1 || channels == 2) &&
              bitsPerSample == 16;
          logger.d('iOS compatibility: $isIOSCompatible');

          if (!isIOSCompatible) {
            logger
              ..w('Warning: File may not be fully compatible with iOS')
              ..w('Expected: 44.1kHz, 1-2 channels, 16-bit')
              ..w(
                'Found: ${sampleRate}Hz,$channels channels,$bitsPerSample-bit',
              );
          }
        }
      }

      return file;
    } on Exception catch (e) {
      logger.e('Failed to download file: $e');
      rethrow;
    }
  }

  /// 音楽を再生するメソッド
  void play() {
    logger
      ..d('=== 音楽再生開始 ===')
      ..d('現在の再生状態: ${state.isPlaying}')
      ..d('現在の再生位置: ${state.position}')
      ..d('総再生時間: ${state.duration}');

    try {
      // シミュレーターでの音声再生を改善
      _audioPlayer
        ..setVolume(1) // 音量を最大に設定
        ..setSpeed(1) // 再生速度を1.0に設定
        ..play();
      logger.d('play()メソッドが正常に呼び出されました');

      // 音声レベルを確認
      _audioPlayer.volumeStream.listen((volume) {
        logger.d('現在の音量: $volume');
      });
    } on Exception catch (e) {
      logger.e('音楽再生中にエラーが発生しました: $e');
      rethrow;
    }
  }

  /// 音楽を一時停止するメソッド
  void pause() {
    logger
      ..d('=== 音楽一時停止 ===')
      ..d('現在の再生状態: ${state.isPlaying}')
      ..d('現在の再生位置: ${state.position}');

    try {
      _audioPlayer.pause();
      logger.d('pause()メソッドが正常に呼び出されました');
    } on Exception catch (e) {
      logger.e('音楽一時停止中にエラーが発生しました: $e');
      rethrow;
    }
  }

  /// 音楽の再生位置を変更するメソッド
  ///
  /// [position] 新しい再生位置
  void seek(Duration position) {
    logger
      ..d('=== 再生位置変更 ===')
      ..d('変更前の位置: ${state.position}')
      ..d('変更後の位置: $position');

    try {
      _audioPlayer.seek(position);
      logger.d('seek()メソッドが正常に呼び出されました');
    } on Exception catch (e) {
      logger.e('再生位置変更中にエラーが発生しました: $e');
      rethrow;
    }
  }

  /// 再生タイマーを設定するメソッド
  ///
  /// [duration] タイマーの長さ。Duration.zeroでタイマーを解除。
  Future<void> setTimer(Duration duration) async {
    state = state.copyWith(timerDuration: duration);
    if (duration == Duration.zero || state.duration == null) {
      await _audioPlayer.setClip(start: Duration.zero, end: state.duration);
    } else {
      final endPosition = state.position + duration;
      await _audioPlayer.setClip(
        start: state.position,
        end: endPosition > state.duration! ? state.duration : endPosition,
      );
    }
  }

  /// デバッグ用の音声テストメソッド
  Future<void> testAudio() async {
    logger.d('=== 音声テスト開始 ===');

    try {
      // Firebase Storageのテスト用URL
      const testUrl =
          'https://firebasestorage.googleapis.com/v0/b/crelve-paw-harmony-ai-dev.firebasestorage.app/o/generated_music%2F57746176-a207-41ee-add9-63ec2e70a934.wav?alt=media&token=43a5e492-ebc1-4716-b4ec-9abe85ba22fc';

      logger.d('テストURL: $testUrl');

      // 既存の音楽を停止
      await _audioPlayer.stop();
      logger.d('既存の音楽を停止しました');

      // URL設定を試行
      await _audioPlayer.setUrl(testUrl);
      logger.d('URL設定完了');

      // 音量設定
      await _audioPlayer.setVolume(1);
      logger.d('音量設定完了');

      // 再生開始
      await _audioPlayer.play();
      logger.d('Firebase Storageのテスト音声を再生しました');

      // 10秒後に停止
      Future.delayed(const Duration(seconds: 10), () async {
        await _audioPlayer.stop();
        logger.d('テスト音声を停止しました');
      });
    } on PlayerException catch (e) {
      logger.e('プレイヤーエラー: ${e.code} - ${e.message}');
      // 代替テスト音声を試行
      await _testWithFallbackAudio();
    } on Exception catch (e) {
      logger.e('音声テスト中にエラーが発生しました: $e');
      // 代替テスト音声を試行
      await _testWithFallbackAudio();
    }
  }

  /// 代替テスト音声を使用したテスト
  Future<void> _testWithFallbackAudio() async {
    logger.d('=== 代替音声テスト開始 ===');

    try {
      // 短いテスト音声（ビープ音）
      const fallbackUrl =
          'data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBSuBzvLZiTYIG2m98OScTgwOUarm7blmGgU7k9n1unEiBC13yO/eizEIHWq+8+OWT';

      logger.d('代替URL: $fallbackUrl');

      await _audioPlayer.setUrl(fallbackUrl);
      await _audioPlayer.setVolume(1);
      await _audioPlayer.play();

      logger.d('代替テスト音声を再生しました');

      // 3秒後に停止
      Future.delayed(const Duration(seconds: 3), () async {
        await _audioPlayer.stop();
        logger.d('代替テスト音声を停止しました');
      });
    } on Exception catch (e) {
      logger.e('代替音声テスト中にエラーが発生しました: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// MusicPlayerStateNotifierを提供するProvider
final AutoDisposeStateNotifierProvider<MusicPlayerStateNotifier, PlayerState>
musicPlayerProvider =
    StateNotifierProvider.autoDispose<MusicPlayerStateNotifier, PlayerState>(
      (ref) => MusicPlayerStateNotifier(),
    );
