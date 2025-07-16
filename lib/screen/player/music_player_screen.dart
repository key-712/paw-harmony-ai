// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// 音楽再生画面のウィジェット
class MusicPlayerScreen extends HookConsumerWidget {
  /// MusicPlayerScreenのコンストラクタ
  ///
  /// [musicUrl] 再生する音楽のURL
  const MusicPlayerScreen({super.key, required this.musicUrl});

  /// 再生する音楽のURL
  final String musicUrl;

  @override
  /// 音楽再生画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final playerNotifier = ref.read(musicPlayerProvider.notifier);
    final playerState = ref.watch(musicPlayerProvider);
    final rating = useState(3);
    final selectedTags = useState<List<String>>([]);
    final commentController = useTextEditingController();

    // 音楽URLの設定を一度だけ実行
    useEffect(() {
      Future.microtask(() async {
        if (!context.mounted) return;
        try {
          await playerNotifier.setUrl(musicUrl, context);
        } on Exception catch (e) {
          logger.e('音楽の再生に失敗しました。アプリを再起動してください。', error: e);
          if (!context.mounted) return;
          showSnackBar(
            context: context,
            theme: theme,
            text: '音楽の再生に失敗しました。アプリを再起動してください。',
          );
        }
      });
      return null;
    }, [musicUrl]);

    return Scaffold(
      appBar: BackIconHeader(title: l10n.nowPlaying),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ThemeText(
              text: l10n.relaxSound,
              color: theme.appColors.black,
              style: theme.textTheme.h30.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            hSpace(height: 32),
            Slider(
              value: playerState.position.inSeconds.toDouble(),
              max: playerState.duration?.inSeconds.toDouble() ?? 0.0,
              onChanged: (value) {
                playerNotifier.seek(Duration(seconds: value.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ThemeText(
                    text: _formatDuration(playerState.position),
                    color: ref.watch(appThemeProvider).appColors.black,
                    style: ref.watch(appThemeProvider).textTheme.h30,
                  ),
                  ThemeText(
                    text: _formatDuration(
                      playerState.duration ?? Duration.zero,
                    ),
                    color: ref.watch(appThemeProvider).appColors.black,
                    style: ref.watch(appThemeProvider).textTheme.h30,
                  ),
                ],
              ),
            ),
            hSpace(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    playerState.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  iconSize: 64,
                  onPressed:
                      () =>
                          playerState.isPlaying
                              ? playerNotifier.pause()
                              : playerNotifier.play(),
                ),
              ],
            ),
            SecondaryButton(
              text:
                  playerState.timerDuration == null
                      ? l10n.setPlaybackTimer
                      : l10n.timerSet(
                        _formatDuration(playerState.timerDuration!),
                      ),
              screen: 'music_player_screen',
              width: double.infinity,
              isDisabled: false,
              callback: () async {
                final selectedDuration = await showModalBottomSheet<Duration>(
                  context: context,
                  builder: (BuildContext context) {
                    return _TimerSettingSheet(
                      initialDuration: playerState.timerDuration,
                    );
                  },
                );
                if (selectedDuration != null) {
                  await playerNotifier.setTimer(selectedDuration);
                }
              },
            ),
            hSpace(height: 32),
            ThemeText(
              text: l10n.rateDogReaction,
              color: theme.appColors.black,
              style: theme.textTheme.h30.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < rating.value ? Icons.star : Icons.star_border,
                  ),
                  onPressed: () => rating.value = index + 1,
                  color: Colors.amber,
                ),
              ),
            ),
            hSpace(height: 16),
            MultiSelectChip(
              choices: [
                l10n.stoppedBarking,
                l10n.calmedDownAndSlept,
                l10n.restless,
                l10n.breathingBecameCalm,
              ],
              selectedChoices: selectedTags.value,
              onSelectionChanged: (selectedList) {
                selectedTags.value = selectedList;
              },
            ),
            hSpace(height: 16),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: l10n.commentOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            hSpace(height: 24),
            PrimaryButton(
              text: l10n.sendFeedback,
              screen: 'music_player_screen',
              width: double.infinity,
              isDisabled: true, // 一時的に無効化（musicHistoryが利用できないため）
              callback: () {
                // TODO(kii): フィードバック機能を実装
                showSnackBar(
                  context: context,
                  theme: theme,
                  text: l10n.feedbackUnderDevelopment,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 時間をフォーマットするメソッド
  ///
  /// [duration] フォーマットする時間
  /// Returns フォーマットされた時間文字列（HH:MM:SS形式）
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}

/// タイマー設定用のボトムシートウィジェット
class _TimerSettingSheet extends HookConsumerWidget {
  /// _TimerSettingSheetのコンストラクタ
  const _TimerSettingSheet({this.initialDuration});

  /// 初期設定時間
  final Duration? initialDuration;

  @override
  /// タイマー設定シートを構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final selectedDuration = useState(initialDuration ?? Duration.zero);

    final timerOptions = <Map<String, dynamic>>[
      {'label': l10n.off, 'duration': Duration.zero},
      {'label': l10n.minutes(15), 'duration': const Duration(minutes: 15)},
      {'label': l10n.minutes(30), 'duration': const Duration(minutes: 30)},
      {'label': l10n.hours(1), 'duration': const Duration(hours: 1)},
      {'label': l10n.hours(2), 'duration': const Duration(hours: 2)},
      {'label': l10n.hours(3), 'duration': const Duration(hours: 3)},
      {
        'label': l10n.continuousPlayback,
        'duration': const Duration(days: 365),
      }, // 実質無制限
    ];

    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ThemeText(
              text: l10n.setPlaybackTimer,
              color: theme.appColors.black,
              style: theme.textTheme.h30.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: timerOptions.length,
              itemBuilder: (context, index) {
                final option = timerOptions[index];
                return ListTile(
                  title: ThemeText(
                    text: option['label'] as String,
                    color: theme.appColors.black,
                    style: theme.textTheme.h30,
                  ),
                  trailing:
                      selectedDuration.value == option['duration']
                          ? const Icon(Icons.check)
                          : null,
                  onTap: () {
                    selectedDuration.value = option['duration'] as Duration;
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CancelButton(
                  text: l10n.cancel,
                  screen: 'music_player_screen',
                  width: 100,
                  isDisabled: false,
                  callback: () {
                    if (!context.mounted) return;
                    GoRouter.of(context).pop();
                  },
                ),
                wSpace(width: 8),
                PrimaryButton(
                  text: l10n.setting,
                  screen: 'music_player_screen',
                  width: 100,
                  isDisabled: false,
                  callback: () {
                    if (!context.mounted) return;
                    Navigator.of(context).pop(selectedDuration.value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
