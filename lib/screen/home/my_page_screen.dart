/// マイページ画面
// ignore_for_file: lines_longer_than_80_chars

library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/model.dart';
import '../../import/provider.dart';
import '../../import/route.dart';
import '../../import/theme.dart';

/// マイページ画面のウィジェット
class MyPageScreen extends HookConsumerWidget {
  /// MyPageScreenのコンストラクタ
  const MyPageScreen({super.key, required this.scrollController});

  /// スクロールコントローラー
  final ScrollController scrollController;

  @override
  /// マイページ画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final dogProfile = ref.watch(dogProfileStateNotifierProvider);
    final musicHistory = ref.watch(musicHistoryStreamProvider); // 変更
    final theme = ref.watch(appThemeProvider);

    return Scaffold(
      appBar: const BaseHeader(title: 'マイページ'),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// プロフィールセクション
            dogProfile.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, stack) => Center(
                    child: ThemeText(
                      text: 'エラー: $err',
                      color: theme.appColors.black,
                      style: theme.textTheme.h30,
                    ),
                  ),
              data: (profile) {
                if (profile == null) {
                  return Center(
                    child: ThemeText(
                      text: '犬のプロフィールが登録されていません。',
                      color: theme.appColors.black,
                      style: theme.textTheme.h30,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              profile.profileImageUrl != null
                                  ? NetworkImage(profile.profileImageUrl!)
                                  : null,
                          child:
                              profile.profileImageUrl == null
                                  ? const Icon(Icons.pets, size: 30)
                                  : null,
                        ),
                        wSpace(width: 16),
                        Expanded(
                          child: ThemeText(
                            text: profile.name,
                            color: theme.appColors.black,
                            style: theme.textTheme.h30.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PrimaryButton(
                          text: '編集',
                          screen: 'my_page_screen',
                          width: 120,
                          isDisabled: false,
                          callback:
                              () => const DogProfileScreenRoute().push<void>(
                                context,
                              ),
                        ),
                      ],
                    ),
                    hSpace(height: 24),
                  ],
                );
              },
            ),

            /// 音楽再生履歴セクション
            Row(
              children: [
                ThemeText(
                  text: '音楽再生履歴',
                  color: theme.appColors.black,
                  style: theme.textTheme.h30.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.music_note,
                  color: theme.appColors.primary,
                  size: 24,
                ),
              ],
            ),
            hSpace(height: 16),
            musicHistory.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, stack) => Center(
                    child: ThemeText(
                      text: 'エラー: $err',
                      color: theme.appColors.black,
                      style: theme.textTheme.h30,
                    ),
                  ),
              data: (List<MusicGenerationHistory> history) {
                // 型を明示
                if (history.isEmpty) {
                  // nullチェックを削除
                  return Center(
                    child: ThemeText(
                      text: '音楽再生履歴はありません。',
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
                      child: Padding(
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
                                        text:
                                            '生成日時: ${item.createdAt.toLocal().toString().split(' ')[0]}',
                                        color: theme.appColors.black,
                                        style: theme.textTheme.h30.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      hSpace(height: 4),
                                      ThemeText(
                                        text: 'シーン: ${item.scenario}',
                                        color: theme.appColors.grey,
                                        style: theme.textTheme.h30.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      ThemeText(
                                        text: '状態: ${item.dogCondition}',
                                        color: theme.appColors.grey,
                                        style: theme.textTheme.h30.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      ThemeText(
                                        text: '品種: ${item.dogBreed}',
                                        color: theme.appColors.grey,
                                        style: theme.textTheme.h30.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                      ThemeText(
                                        text: '再生時間: ${item.duration}秒',
                                        color: theme.appColors.grey,
                                        style: theme.textTheme.h30.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: theme.appColors.primary,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.appColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      /// 音楽再生画面へ遷移
                                      MusicPlayerScreenRoute(
                                        musicUrl: item.generatedMusicUrl,
                                      ).push<void>(context);
                                    },
                                  ),
                                ),
                              ],
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
}
