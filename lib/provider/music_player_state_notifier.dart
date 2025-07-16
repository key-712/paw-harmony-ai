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
      // プラグインの初期化状態をチェック
      if (!_isPluginInitialized()) {
        logger.e('just_audio plugin not initialized');
        if (!context.mounted) return;
        state = state.copyWith(
          appError: AppError(
            error: Exception('Audio plugin not available'),
            context: context,
          ),
        );
        return;
      }

      // URLの形式をログ出力
      logger.d('Setting URL: $url');

      // URLの妥当性をチェック
      if (url.isEmpty) {
        throw Exception('URL is empty');
      }

      // Firebase Storage URLの場合、ファイルをダウンロードしてから再生
      if (url.contains('firebase')) {
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
          try {
            // iOSでは、ファイルパスを直接設定する前に少し待機
            await Future.delayed(const Duration(milliseconds: 100));
            await _audioPlayer.setFilePath(localFile.path);
            logger.d('Local file set successfully for iOS');
            return;
          } on PlayerException catch (e) {
            logger.e('Player exception when setting local file: $e');
            logger.e('Error code: ${e.code}');
            logger.e('Error message: ${e.message}');

            // iOS固有のエラーコードをチェック
            if (e.code == -11800) {
              logger.e('iOS audio session error detected');
              // iOSのオーディオセッションをリセットして再試行
              try {
                await _audioPlayer.stop();
                await Future.delayed(const Duration(milliseconds: 500));
                await _audioPlayer.setFilePath(localFile.path);
                logger.d('iOS audio session reset and file set successfully');
                return;
              } on PlayerException catch (e2) {
                logger.e('iOS audio session reset failed: $e2');
                rethrow;
              }
            }
            rethrow;
          }
        } on Exception catch (e) {
          logger.e('Failed to download or set local file: $e');
          // ダウンロードに失敗した場合は、元のURLで直接再生を試行
          logger.d('Falling back to direct URL playback...');
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

      logger.d('HTTP Response Status: ${response.statusCode}');
      logger.d('HTTP Response Headers: ${response.headers}');
      logger.d('Response body size: ${response.bodyBytes.length} bytes');

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

        logger.d('File header: $header');
        logger.d('WAVE identifier: $wave');
        logger.d('Format chunk: $fmt');
        logger.d('Data chunk: $data');

        if (header != 'RIFF' ||
            wave != 'WAVE' ||
            fmt != 'fmt ' ||
            data != 'data') {
          logger.w('Warning: File does not appear to be a valid WAV file');
          logger.w('Expected: RIFF, WAVE, fmt , data');
          logger.w('Found: $header, $wave, $fmt, $data');
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
            logger.w('Warning: File may not be fully compatible with iOS');
            logger.w('Expected: 44.1kHz, 1-2 channels, 16-bit');
            logger.w(
              'Found: ${sampleRate}Hz, $channels channels, $bitsPerSample-bit',
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

  /// プラグインが初期化されているかチェック
  bool _isPluginInitialized() {
    try {
      // 簡単なテストでプラグインの状態を確認
      return _audioPlayer != null;
    } on Exception catch (e) {
      logger.e('Plugin initialization check failed: $e');
      return false;
    }
  }

  /// 音楽を再生するメソッド
  void play() => _audioPlayer.play();

  /// 音楽を一時停止するメソッド
  void pause() => _audioPlayer.pause();

  /// 音楽の再生位置を変更するメソッド
  ///
  /// [position] 新しい再生位置
  void seek(Duration position) => _audioPlayer.seek(position);

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
