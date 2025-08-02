/// プレイヤーリスト画面
// ignore_for_file: lines_longer_than_80_chars

library;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/model.dart';
import '../../import/provider.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// プレイヤーリスト画面のウィジェット
class PlayerListScreen extends HookConsumerWidget {
  /// PlayerListScreenのコンストラクタ
  const PlayerListScreen({super.key, required this.scrollController});

  /// スクロールコントローラー
  final ScrollController scrollController;

  @override
  /// プレイヤーリスト画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final musicHistory = ref.watch(musicHistoryStreamProvider);
    final playerNotifier = ref.read(musicPlayerProvider.notifier);
    final selectedMusicItem = useState<MusicGenerationHistory?>(null);

    // 音楽URLの設定を一度だけ実行
    useEffect(() {
      if (selectedMusicItem.value != null) {
        Future.microtask(() async {
          if (!context.mounted) return;
          try {
            await playerNotifier.setUrl(
              selectedMusicItem.value!.generatedMusicUrl,
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
    }, [selectedMusicItem.value?.generatedMusicUrl]);

    return Scaffold(
      appBar: BaseHeader(title: l10n.playerList),
      backgroundColor: theme.appColors.background,
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            musicHistory.when(
              loading: () => const Center(child: Loading()),
              error:
                  (err, stack) => Center(
                    child: ThemeText(
                      text: l10n.errorOccurred,
                      color: theme.appColors.black,
                      style: theme.textTheme.h30,
                    ),
                  ),
              data: (List<MusicGenerationHistory> history) {
                if (history.isEmpty) {
                  return Center(
                    child: ThemeText(
                      text: l10n.noMusicPlaybackHistory,
                      color: theme.appColors.black,
                      style: theme.textTheme.h30,
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () {
                          MusicDetailRoute(
                            musicId: item.id,
                          ).push<void>(context);
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ThemeText(
                                              text: l10n.generatedAt(
                                                _formatGeneratedAt(
                                                  item.createdAt,
                                                ),
                                              ),
                                              color: theme.appColors.black,
                                              style: theme.textTheme.h30
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),

                                            hSpace(height: 4),
                                            ThemeText(
                                              text: l10n.sceneTitle,
                                              color: theme.appColors.black,
                                              style: theme.textTheme.h30
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                            ),
                                            ThemeText(
                                              text:
                                                  buildSceneIdToLabelMap(
                                                    l10n,
                                                  )[item.scenario] ??
                                                  item.scenario,
                                              color: theme.appColors.black,
                                              style: theme.textTheme.h30,
                                            ),
                                            hSpace(height: 4),
                                            ThemeText(
                                              text: l10n.conditionTitle,
                                              color: theme.appColors.black,
                                              style: theme.textTheme.h30
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                            ),
                                            ThemeText(
                                              text:
                                                  buildConditionIdToLabelMap(
                                                    l10n,
                                                  )[item.dogCondition] ??
                                                  item.dogCondition,
                                              color: theme.appColors.black,
                                              style:
                                                  theme.textTheme.h30
                                                      .copyWith(),
                                            ),
                                            hSpace(height: 4),
                                            ThemeText(
                                              text: l10n.breedTitle,
                                              color: theme.appColors.black,
                                              style: theme.textTheme.h30
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                            ),
                                            ThemeText(
                                              text: getL10nValue(
                                                l10n,
                                                getBreedKey(item.dogBreed),
                                              ),
                                              color: theme.appColors.black,
                                              style: theme.textTheme.h30,
                                            ),
                                            hSpace(height: 4),
                                            ThemeText(
                                              text: l10n.durationTitle,
                                              color: theme.appColors.black,
                                              style: theme.textTheme.h30
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                            ),
                                            ThemeText(
                                              text: l10n.duration(
                                                item.duration,
                                              ),
                                              color: theme.appColors.black,
                                              style: theme.textTheme.h30,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 生成日時をフォーマットするメソッド
  ///
  /// [createdAt] 生成日時
  /// Returns フォーマットされた日時文字列（直近1週間は時間も含む）
  String _formatGeneratedAt(DateTime createdAt) {
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
