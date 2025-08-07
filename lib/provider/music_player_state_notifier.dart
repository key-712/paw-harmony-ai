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
      _audioPlayer.positionStream.listen((position) {
        state = state.copyWith(position: position);
      });

      _audioPlayer.durationStream.listen((duration) {
        state = state.copyWith(duration: duration);
      });

      _audioPlayer.playingStream.listen((isPlaying) {
        state = state.copyWith(isPlaying: isPlaying);
      });
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
      // URLの妥当性をチェック
      if (url.isEmpty) {
        throw Exception('URL is empty');
      }

      // Firebase Storage URLの場合、ファイルをダウンロードしてから再生
      if (url.contains('firebase') && !url.contains('data:audio')) {
        try {
          final localFile = await _downloadAndSaveFile(url);
          // ファイルの存在確認
          if (!localFile.existsSync()) {
            throw Exception('Downloaded file does not exist');
          }

          final fileBytes = await localFile.readAsBytes();
          if (fileBytes.length >= 4) {
            final header = String.fromCharCodes(fileBytes.take(4));

            if (header != 'RIFF') {
              logger.w('Warning: File does not appear to be a valid WAV file');
            }
          }

          await _audioPlayer.setFilePath(localFile.path);
          logger.d('Local file set successfully');

          /// ここで再生を可能にする
          return;
        } on Exception catch (e) {
          logger
            ..e('Failed to download or set local file: $e')
            // ダウンロードに失敗した場合、直接URL再生を試行
            ..d('Trying direct URL playback as fallback...');

          // 直接URL再生も試行
          try {
            await _audioPlayer.setUrl(url);
            return;
          } on Exception catch (e2) {
            logger.e('Direct URL playback also failed: $e2');
            // 最後の手段として、URLを再構築して試行
            try {
              final baseUrl = url.split('?')[0];
              final newUrl = '$baseUrl?alt=media';
              await _audioPlayer.setUrl(newUrl);
              return;
            } on Exception catch (e3) {
              logger.e('All URL methods failed: $e3');
              rethrow;
            }
          }
        }
      }

      // Firebase Storage URLの場合、Base64データとして直接再生を試行
      if (url.contains('firebase') && url.contains('data:audio')) {
        try {
          // Base64データを抽出
          final dataIndex = url.indexOf(',');
          if (dataIndex != -1) {
            final base64Data = url.substring(dataIndex + 1);

            // Base64データをデコードして一時ファイルに保存
            final bytes = base64Decode(base64Data);
            final tempDir = await getTemporaryDirectory();
            final fileName =
                'music_base64_${DateTime.now().millisecondsSinceEpoch}.wav';
            final file = File('${tempDir.path}/$fileName');

            await file.writeAsBytes(bytes);
            await _audioPlayer.setFilePath(file.path);
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
      }

      // 最適化されたWAVファイルの処理
      if (processedUrl.contains('.wav')) {
      } else if (processedUrl.contains('.mp3')) {}

      // より詳細なエラーハンドリングでURL設定を試行
      try {
        await _audioPlayer.setUrl(processedUrl);
      } on PlayerException catch (e) {
        logger.e('Player exception during setUrl: $e');

        // 代替方法を試行：URLを再エンコード
        try {
          final reencodedUrl = Uri.encodeFull(processedUrl);
          await _audioPlayer.setUrl(reencodedUrl);
        } on PlayerException catch (e2) {
          logger
            ..e('Player exception with reencoded URL: $e2')
            ..d('Trying download as last resort...');
          try {
            final localFile = await _downloadAndSaveFile(processedUrl);
            await _audioPlayer.setFilePath(localFile.path);
            logger.d('Download and set file path successful');
          } on Exception catch (e3) {
            logger.e('All methods failed: $e3');
            rethrow;
          }
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
      final uri = Uri.parse(url);

      // HTTPリクエストを送信（タイムアウトを設定）
      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'PawHarmonyAI/1.0',
              'Accept': 'audio/wav, audio/*, */*',
              'Cache-Control': 'no-cache',
            },
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        logger
          ..e('HTTP Error: ${response.statusCode}')
          ..e('Response body: ${response.body}')
          ..e('Response headers: ${response.headers}');

        if (response.statusCode == 404) {
          logger.w('404エラーが発生しました。URLを再構築して試行します...');

          if (url.contains('firebase')) {
            try {
              final baseUrl = url.split('?')[0];
              final newUrl = '$baseUrl?alt=media';

              final newResponse = await http
                  .get(
                    Uri.parse(newUrl),
                    headers: {
                      'User-Agent': 'PawHarmonyAI/1.0',
                      'Accept': 'audio/wav, audio/*, */*',
                      'Cache-Control': 'no-cache',
                    },
                  )
                  .timeout(const Duration(seconds: 30));

              if (newResponse.statusCode == 200) {
                return await _saveFileFromResponse(newResponse);
              } else {
                logger.e('新しいURLでも失敗: ${newResponse.statusCode}');
              }
            } on Exception catch (e) {
              logger.e('新しいURLでの試行中にエラー: $e');
            }
          }
        }

        throw Exception('Failed to download file: HTTP ${response.statusCode}');
      }

      if (response.bodyBytes.isEmpty) {
        throw Exception('Downloaded file is empty');
      }

      return await _saveFileFromResponse(response);
    } on Exception catch (e) {
      logger.e('Failed to download file: $e');

      if (e.toString().contains('timeout') ||
          e.toString().contains('connection')) {
        logger.d('Network error detected, retrying...');
        await Future<void>.delayed(const Duration(seconds: 2));
        return _downloadAndSaveFile(url);
      }

      rethrow;
    }
  }

  /// HTTPレスポンスからファイルを保存するヘルパーメソッド
  Future<File> _saveFileFromResponse(http.Response response) async {
    // 一時ディレクトリを取得
    final tempDir = await getTemporaryDirectory();

    final fileName = 'music_${DateTime.now().millisecondsSinceEpoch}.wav';
    final file = File('${tempDir.path}/$fileName');

    // ファイルに書き込み
    await file.writeAsBytes(response.bodyBytes);

    // ファイルの存在を確認
    if (!file.existsSync()) {
      throw Exception('File was not saved properly');
    }

    // ファイルサイズを確認
    final fileSize = await file.length();

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
        final channels = fileBytes[22] | (fileBytes[23] << 8);
        final bitsPerSample = fileBytes[34] | (fileBytes[35] << 8);

        // iOS互換性チェック
        final isIOSCompatible =
            sampleRate == 44100 &&
            (channels == 1 || channels == 2) &&
            bitsPerSample == 16;

        if (!isIOSCompatible) {
          logger
            ..w('Warning: File may not be fully compatible with iOS')
            ..w('Expected: 44.1kHz, 1-2 channels, 16-bit')
            ..w('Found: ${sampleRate}Hz,$channels channels,$bitsPerSample-bit');
        }
      }
    } else {
      logger.w('File is too small to be a valid WAV file');
    }

    return file;
  }

  /// 音楽を再生するメソッド
  void play() {
    try {
      if (_audioPlayer.processingState == ProcessingState.completed) {
        _loadCurrentAudioFile();
      }

      // 音量と速度を設定
      _audioPlayer
        ..setVolume(1)
        ..setSpeed(1);

      // 再生開始前に少し待機
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          // 再生開始
          _audioPlayer.play();
          logger.d('play()メソッドが正常に呼び出されました');
        } on Exception catch (e) {
          logger.e('再生開始中にエラーが発生しました: $e');
        }
      });

      // 音声レベルを確認
      _audioPlayer.volumeStream.listen((volume) {
        logger.d('現在の音量: $volume');
      });

      // 再生状態を監視
      _audioPlayer.playingStream.listen((isPlaying) {
        logger.d('再生状態変更: ${isPlaying ? "再生中" : "停止中"}');
      });

      // エラー状態を監視
      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.idle) {
          logger.w('プレイヤーがアイドル状態です');
        }
      });
    } on Exception catch (e) {
      logger.e('音楽再生中にエラーが発生しました: $e');
      rethrow;
    }
  }

  /// 現在の音声ファイルを再読み込み
  Future<void> _loadCurrentAudioFile() async {
    try {
      // 現在のURLを再設定
      if (state.duration != null) {
        logger.d('音声ファイルを再読み込みします');
        // ここで現在のURLを再設定する必要があります
      }
    } on Exception catch (e) {
      logger.e('音声ファイル再読み込み中にエラーが発生しました: $e');
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

  /// 音楽を停止するメソッド
  void stop() {
    logger
      ..d('=== 音楽停止 ===')
      ..d('現在の再生状態: ${state.isPlaying}')
      ..d('現在の再生位置: ${state.position}');

    try {
      _audioPlayer.stop();
      logger.d('stop()メソッドが正常に呼び出されました');
    } on Exception catch (e) {
      logger.e('音楽停止中にエラーが発生しました: $e');
      rethrow;
    }
  }

  /// 再生速度を設定するメソッド
  ///
  /// [speed] 再生速度（0.5-2.0の範囲）
  void setPlaybackSpeed(double speed) {
    logger
      ..d('=== 再生速度設定 ===')
      ..d('設定する速度: $speed');

    try {
      _audioPlayer.setSpeed(speed);
    } on Exception catch (e) {
      logger.e('再生速度設定中にエラーが発生しました: $e');
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

  /// 音声セッションを強制初期化するメソッド
  Future<void> forceAudioSessionInit() async {
    logger.d('=== 音声セッション強制初期化開始 ===');

    try {
      await _audioPlayer.stop();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // 音量を0にしてから1に戻す
      await _audioPlayer.setVolume(0);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.setVolume(1);

      // 再生状態をリセット
      await _audioPlayer.seek(Duration.zero);

      logger.d('音声セッション初期化完了');
    } on Exception catch (e) {
      logger.e('音声セッション初期化中にエラーが発生しました: $e');
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
