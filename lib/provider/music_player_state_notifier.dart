// PlayerStateをfreezedで定義
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

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
    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });
    _audioPlayer.durationStream.listen((duration) {
      state = state.copyWith(duration: duration);
    });
    _audioPlayer.playingStream.listen((isPlaying) {
      state = state.copyWith(isPlaying: isPlaying);
    });
  }

  /// オーディオプレイヤーのインスタンス
  final AudioPlayer _audioPlayer;

  /// 音楽URLを設定するメソッド
  ///
  /// [url] 再生する音楽のURL
  Future<void> setUrl(String url, BuildContext context) async {
    try {
      await _audioPlayer.setUrl(url);
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
