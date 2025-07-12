import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../import/component.dart';
import '../../import/model.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../utility/logger/logger.dart';

/// AI音楽生成画面のウィジェット
class AiMusicGenerateScreen extends HookConsumerWidget {
  /// AiMusicGenerateScreenのコンストラクタ
  const AiMusicGenerateScreen({super.key, required this.scrollController});

  /// スクロールコントローラー
  final ScrollController scrollController;

  @override
  /// AI音楽生成画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final dogProfile = ref.watch(dogProfileStateNotifierProvider);
    final selectedScene = useState<String?>(null);
    final selectedCondition = useState<String?>(null);
    final additionalInfoController = useTextEditingController();
    final purchaseState = ref.watch(purchaseStateNotifierProvider);
    final theme = ref.watch(appThemeProvider);
    final isDialogShowing = useState(false); // Moved to top

    // HTMLコンテンツを非同期でロード
    final htmlContentFuture = useMemoized(
      () => rootBundle.loadString('assets/web/music_generator.html'),
    );
    final htmlContentSnapshot = useFuture(htmlContentFuture);

    // WebViewコントローラーの初期化
    final webViewController = useMemoized(WebViewController.new);

    ref.listen<AsyncValue<MusicGenerationHistory?>>(
      musicGenerationStateNotifierProvider,
      (_, state) {
        if (!context.mounted) return;

        logger
          ..d('=== 音楽生成状態変更 ===')
          ..d('状態: $state')
          ..d('ダイアログ表示中: ${isDialogShowing.value}');

        // 音楽生成が完了またはエラーになった場合のみ、ダイアログを閉じる
        if (isDialogShowing.value &&
            (state is AsyncData || state is AsyncError)) {
          logger.d('音楽生成が完了またはエラーになったため、ダイアログを閉じます');
          Navigator.of(context).pop();
          isDialogShowing.value = false;
        }

        if (state is AsyncData && state.value != null) {
          logger.d('音楽生成完了: ${state.value?.id}');
          // 音楽生成完了の通知を表示
          showSnackBar(
            context: context,
            theme: theme,
            text: '🎵 音楽の生成が完了しました！マイページの「音楽再生履歴」で再生できます。',
          );
        } else if (state is AsyncError) {
          logger.d('音楽生成エラー: ${state.error}');
          showAlertSnackBar(
            context: context,
            theme: theme,
            text: '音楽の生成に失敗しました: ${state.error}',
          );
        }
      },
    );

    final scenes = ['留守番中', '就寝前', 'ストレスフル', '長距離移動中', '日常の癒し', '療養/高齢犬ケア'];
    final conditions = ['落ち着かせたい', 'リラックスさせたい', '興奮を抑えたい', '安心させたい', '安眠させたい'];

    return Scaffold(
      appBar: const BaseHeader(title: 'PawHarmony AI'),
      body: dogProfile.when(
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
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ThemeText(
                  text: '利用シーンを選択',
                  color: theme.appColors.black,
                  style: theme.textTheme.h30.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SingleSelectChip(
                  choices: scenes,
                  selectedChoice: selectedScene.value,
                  onSelectionChanged: (selected) {
                    selectedScene.value = selected;
                  },
                ),
                hSpace(height: 24),
                ThemeText(
                  text: '犬の状態を選択',
                  color: theme.appColors.black,
                  style: theme.textTheme.h30.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SingleSelectChip(
                  choices: conditions,
                  selectedChoice: selectedCondition.value,
                  onSelectionChanged: (selected) {
                    selectedCondition.value = selected;
                  },
                ),
                hSpace(height: 24),
                TextField(
                  controller: additionalInfoController,
                  decoration: const InputDecoration(
                    labelText: 'その他（任意）',
                    hintText: '最近、夜泣きが多い、など',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                hSpace(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ThemeText(
                    text:
                        purchaseState.isSubscribed
                            ? '生成回数: 無制限'
                            : '残り生成回数: 3回 (無料版)', // 仮の回数
                    color: theme.appColors.grey,
                    style: theme.textTheme.h30.copyWith(fontSize: 14),
                  ),
                ),
                hSpace(height: 32),
                PrimaryButton(
                  text: '音楽を生成する',
                  screen: 'ai_music_generate_screen',
                  width: double.infinity,
                  isDisabled:
                      selectedScene.value == null ||
                      selectedCondition.value == null ||
                      !(purchaseState.isSubscribed ||
                          // ignore: lines_longer_than_80_chars
                          true), // TODO(dev): Implement actual free trial limit check
                  callback: () async {
                    if (!htmlContentSnapshot.hasData) {
                      showAlertSnackBar(
                        context: context,
                        theme: theme,
                        text: '音楽生成に必要なファイルをロード中です。しばらくお待ちください。',
                      );
                      return;
                    }

                    final request = MusicGenerationRequest(
                      userId: profile.userId,
                      dogId: profile.id,
                      scenario: selectedScene.value!,
                      dogCondition: selectedCondition.value!,
                      additionalInfo: additionalInfoController.text,
                      dogBreed: profile.breed,
                      dogPersonalityTraits: profile.personalityTraits,
                    );

                    // 音楽生成ダイアログを表示
                    isDialogShowing.value = true;
                    logger.d('ダイアログを表示します');

                    // ダイアログを表示してから音楽生成を開始
                    await showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        logger.d('ダイアログビルダーが呼び出されました');
                        return MusicGenerationWebViewDialog(
                          controller: webViewController,
                          htmlContent:
                              htmlContentSnapshot.data!, // Pass htmlContent
                          onWebViewCreated: (controller) {
                            logger.d('WebViewが作成されました');
                            // WebViewが作成されたら少し待ってから音楽生成を開始
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                if (isDialogShowing.value) {
                                  logger.d('音楽生成を開始します');
                                  ref
                                      .read(
                                        musicGenerationStateNotifierProvider
                                            .notifier,
                                      )
                                      .generateMusic(request, controller);
                                }
                              },
                            );
                          },
                        );
                      },
                    );
                    logger.d('ダイアログが閉じられました');
                    isDialogShowing.value = false;
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
