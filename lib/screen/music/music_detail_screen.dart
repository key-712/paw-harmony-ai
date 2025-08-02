/// 音楽詳細画面
// ignore_for_file: lines_longer_than_80_chars

library;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/model.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// 音楽詳細画面のウィジェット
/// 生成した音楽の詳細情報を表示
class MusicDetailScreen extends HookConsumerWidget {
  /// MusicDetailScreenのコンストラクタ
  const MusicDetailScreen({super.key, required this.musicId});

  /// 音楽アイテムのID
  final String musicId;

  @override
  /// 音楽詳細画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final playerNotifier = ref.read(musicPlayerProvider.notifier);
    final playerState = ref.watch(musicPlayerProvider);
    final musicHistory = ref.watch(musicHistoryByIdStreamProvider(musicId));
    final rating = useState(5);
    final selectedTags = useState<List<String>>([]);
    final commentController = useTextEditingController();
    final playbackSpeed = useState<double>(1);

    // TabControllerを追加
    final tabController = useTabController(initialLength: 2);

    // 音楽データが取得できた場合の処理
    useEffect(() {
      if (musicHistory.value != null) {
        Future.microtask(() async {
          if (!context.mounted) return;
          try {
            await playerNotifier.setUrl(
              musicHistory.value!.generatedMusicUrl,
              context,
            );
          } on Exception catch (e) {
            logger.e('音楽の再生に失敗しました。アプリを再起動してください。', error: e);
            if (!context.mounted) return;
            showSnackBar(
              context: context,
              theme: theme,
              text: l10n.musicPlaybackFailed,
            );
          }
        });
      }
      return null;
    }, [musicHistory.value?.generatedMusicUrl]);

    return Scaffold(
      appBar: BackIconHeader(title: l10n.musicDetail),
      backgroundColor: theme.appColors.background,
      body: SafeArea(
        child: musicHistory.when(
          data: (musicItem) {
            if (musicItem == null) {
              return Center(
                child: ThemeText(
                  text: l10n.musicNotFound,
                  color: theme.appColors.black,
                  style: theme.textTheme.h30,
                ),
              );
            }

            return Column(
              children: [
                // タブバーを追加
                ColoredBox(
                  color: theme.appColors.white,
                  child: TabBar(
                    controller: tabController,
                    labelColor: theme.appColors.primary,
                    unselectedLabelColor: theme.appColors.black,
                    indicatorColor: theme.appColors.primary,
                    tabs: [
                      Tab(text: l10n.musicInfo),
                      Tab(text: l10n.dogReaction),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      // 音楽情報タブ
                      _buildMusicInfoTab(
                        context: context,
                        ref: ref,
                        musicItem: musicItem,
                        theme: theme,
                        l10n: l10n,
                        playerNotifier: playerNotifier,
                        playerState: playerState,
                        playbackSpeed: playbackSpeed,
                      ),
                      // 愛犬の反応タブ
                      _buildDogReactionTab(
                        context: context,
                        ref: ref,
                        theme: theme,
                        l10n: l10n,
                        rating: rating,
                        selectedTags: selectedTags,
                        commentController: commentController,
                        musicId: musicId,
                      ),
                    ],
                  ),
                ),
                const AdBanner(),
              ],
            );
          },
          loading: () => const Center(child: Loading()),
          error:
              (error, stackTrace) => Center(
                child: ThemeText(
                  text: '${l10n.errorOccurred}: $error',
                  color: theme.appColors.black,
                  style: theme.textTheme.h30,
                ),
              ),
        ),
      ),
    );
  }

  /// 音楽情報タブを構築するメソッド
  Widget _buildMusicInfoTab({
    required BuildContext context,
    required WidgetRef ref,
    required MusicGenerationHistory musicItem,
    required AppTheme theme,
    required AppLocalizations l10n,
    required MusicPlayerStateNotifier playerNotifier,
    required PlayerState playerState,
    required ValueNotifier<double> playbackSpeed,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 音楽情報カード
        Container(
          decoration: BoxDecoration(
            color: theme.appColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.appColors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThemeText(
                  text: l10n.generatedAt(
                    _formatGeneratedAt(createdAt: musicItem.createdAt),
                  ),
                  color: theme.appColors.black,
                  style: theme.textTheme.h30.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                hSpace(height: 4),
                ThemeText(
                  text: l10n.scene(
                    buildSceneIdToLabelMap(l10n)[musicItem.scenario] ??
                        musicItem.scenario,
                  ),
                  color: theme.appColors.black,
                  style: theme.textTheme.h30,
                ),
                ThemeText(
                  text: l10n.condition(
                    buildConditionIdToLabelMap(l10n)[musicItem.dogCondition] ??
                        musicItem.dogCondition,
                  ),
                  color: theme.appColors.black,
                  style: theme.textTheme.h30,
                ),
                ThemeText(
                  text: l10n.breed(
                    getL10nValue(l10n, getBreedKey(musicItem.dogBreed)),
                  ),
                  color: theme.appColors.black,
                  style: theme.textTheme.h30,
                ),
                ThemeText(
                  text: l10n.duration(musicItem.duration),
                  color: theme.appColors.black,
                  style: theme.textTheme.h30,
                ),
              ],
            ),
          ),
        ),
        hSpace(height: 16),

        // 音楽プレイヤーセクション
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.appColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.appColors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 再生速度選択
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ThemeText(
                          text:
                              '${l10n.playbackSpeed}: ${playbackSpeed.value.toStringAsFixed(2)}x',
                          color: theme.appColors.black,
                          style: theme.textTheme.h30,
                        ),
                      ],
                    ),
                    Slider(
                      value: playbackSpeed.value,
                      min: 0.5,
                      max: 2,
                      divisions: 30,
                      label: '${playbackSpeed.value.toStringAsFixed(2)}x',
                      activeColor: theme.appColors.main,
                      inactiveColor: theme.appColors.grey.withValues(
                        alpha: 0.3,
                      ),
                      thumbColor: theme.appColors.main,
                      onChanged: (value) {
                        playbackSpeed.value = value;
                        playerNotifier.setPlaybackSpeed(value);
                      },
                    ),
                  ],
                ),
                hSpace(height: 16),

                // プログレスバー
                Slider(
                  value: playerState.position.inSeconds.toDouble(),
                  max: playerState.duration?.inSeconds.toDouble() ?? 0.0,
                  activeColor: theme.appColors.main,
                  inactiveColor: theme.appColors.grey.withValues(alpha: 0.3),
                  thumbColor: theme.appColors.main,
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
                        text: _formatDuration(duration: playerState.position),
                        color: theme.appColors.black,
                        style: theme.textTheme.h30,
                      ),
                      ThemeText(
                        text: _formatDuration(
                          duration: playerState.duration ?? Duration.zero,
                        ),
                        color: theme.appColors.black,
                        style: theme.textTheme.h30,
                      ),
                    ],
                  ),
                ),
                hSpace(height: 16),

                // 再生制御ボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () {
                        playerNotifier.seek(Duration.zero);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        playerState.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      iconSize: 48,
                      onPressed: () {
                        if (playerState.isPlaying) {
                          playerNotifier.pause();
                        } else {
                          playerNotifier.play();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: () {
                        playerNotifier.stop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        hSpace(height: 16),
      ],
    );
  }

  /// 愛犬の反応タブを構築するメソッド
  Widget _buildDogReactionTab({
    required BuildContext context,
    required WidgetRef ref,
    required AppTheme theme,
    required AppLocalizations l10n,
    required ValueNotifier<int> rating,
    required ValueNotifier<List<String>> selectedTags,
    required TextEditingController commentController,
    required String musicId,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 愛犬の反応評価セクション
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.appColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.appColors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThemeText(
                  text: l10n.rateDogReaction,
                  color: theme.appColors.black,
                  style: theme.textTheme.h30.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                hSpace(height: 8),
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
              ],
            ),
          ),
        ),
        hSpace(height: 16),

        // タグ選択
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.appColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.appColors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThemeText(
                  text: l10n.selectTags,
                  color: theme.appColors.black,
                  style: theme.textTheme.h30.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                hSpace(height: 8),
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
              ],
            ),
          ),
        ),
        hSpace(height: 16),
        // コメント入力
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.appColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.appColors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThemeText(
                  text: l10n.commentOptional,
                  color: theme.appColors.black,
                  style: theme.textTheme.h30.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                hSpace(height: 8),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        hSpace(height: 16),
        // フィードバック送信ボタン
        PrimaryButton(
          text: l10n.sendFeedback,
          screen: 'music_detail_screen',
          width: double.infinity,
          isDisabled: ref.watch(feedbackStateNotifierProvider).isLoading,
          callback: () async {
            final user = ref.watch(authStateChangesProvider).value;
            final dogProfileState = ref.watch(dogProfileStateNotifierProvider);

            final dogProfile = dogProfileState.when(
              data: (profile) => profile,
              loading: () => null,
              error: (_, _) => null,
            );

            if (user == null || dogProfile == null) {
              showSnackBar(context: context, theme: theme, text: l10n.error);
              return;
            }
            await ref
                .read(feedbackStateNotifierProvider.notifier)
                .submitFeedback(
                  userId: user.uid,
                  dogId: dogProfile.id,
                  musicHistoryId: musicId,
                  rating: rating.value,
                  behaviorTags: selectedTags.value,
                  comment: commentController.text,
                );
            if (context.mounted) {
              showSnackBar(
                context: context,
                theme: theme,
                text: l10n.sendSuccessRequest,
              );
            }
          },
        ),
        hSpace(height: 16),
      ],
    );
  }

  /// 時間をフォーマットするメソッド
  ///
  /// [duration] フォーマットする時間
  /// Returns フォーマットされた時間文字列（HH:MM:SS形式）
  String _formatDuration({required Duration duration}) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  /// 生成日時をフォーマットするメソッド
  ///
  /// [createdAt] 生成日時
  /// Returns フォーマットされた日時文字列（直近1週間は時間も含む）
  String _formatGeneratedAt({required DateTime createdAt}) {
    final now = DateTime.now();
    final localCreatedAt = createdAt.toLocal();
    final difference = now.difference(localCreatedAt);

    // 直近1週間（7日）以内の場合は時間も表示
    if (difference.inDays < 7) {
      final hours = localCreatedAt.hour.toString().padLeft(2, '0');
      final minutes = localCreatedAt.minute.toString().padLeft(2, '0');
      return '${localCreatedAt.toString().split(' ')[0]} $hours:$minutes';
    } else {
      // 1週間以上前の場合は日付のみ
      return localCreatedAt.toString().split(' ')[0];
    }
  }
}
