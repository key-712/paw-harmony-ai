import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/model.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/type.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// 音声生成画面のウィジェット
/// 愛犬の性格と状況に合わせたオリジナル音楽を生成
class AudioGenerationScreen extends HookConsumerWidget {
  /// AudioGenerationScreenのコンストラクタ
  const AudioGenerationScreen({super.key, required this.scrollController});

  /// スクロールコントローラー
  final ScrollController scrollController;

  @override
  /// 音声生成画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dogProfile = ref.watch(dogProfileStateNotifierProvider);
    final additionalInfoController = useTextEditingController();
    final purchaseState = ref.watch(purchaseStateNotifierProvider);
    final theme = ref.watch(appThemeProvider);
    final musicGenerationState = ref.watch(
      musicGenerationStateNotifierProvider,
    );
    final generationCount = ref.watch(generationCountProvider);
    final adNotifier = ref.read(adStateNotifierProvider.notifier);

    useEffect(() {
      adNotifier.loadInterstitialAd();
      return null;
    }, const []);

    // 報酬の状態を監視
    ref
      ..listen<AdState>(adStateNotifierProvider, (previous, next) {
        if (next.hasReward && (previous == null || !previous.hasReward)) {
          // 報酬が付与された場合、Snackbarを表示
          showRewardSnackBar(
            context: context,
            theme: theme,
            text: l10n.adRewardMessage,
          );
          // 報酬をリセット
          adNotifier.resetReward();
        }
      })
      ..listen<AsyncValue<MusicGenerationHistory?>>(
        musicGenerationStateNotifierProvider,
        (_, state) {
          if (!context.mounted) return;

          if (state is AsyncData && state.value != null) {
            showSnackBar(
              context: context,
              theme: theme,
              text: l10n.musicGenerationSuccess,
            );
          } else if (state is AsyncError) {
            showAlertSnackBar(
              context: context,
              theme: theme,
              text: l10n.musicGenerationFailed(state.error.toString()),
            );
          }
        },
      );

    final sceneIdToLabel = buildSceneIdToLabelMap(l10n);
    final conditionIdToLabel = buildConditionIdToLabelMap(l10n);

    final selectedSceneId = useState<String?>(null);
    final selectedConditionId = useState<String?>(null);

    return Scaffold(
      appBar: BaseHeader(title: l10n.audioGeneration),
      backgroundColor: theme.appColors.background,
      body: Stack(
        children: [
          dogProfile.when(
            loading: () => const Center(child: Loading()),
            error:
                (err, stack) => Center(
                  child: ThemeText(
                    text: l10n.errorOccurred,
                    color: theme.appColors.black,
                    style: theme.textTheme.h30,
                  ),
                ),
            data: (profile) {
              if (profile == null) {
                return Center(
                  child: ThemeText(
                    text: l10n.noDogProfileRegistered,
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
                      text: l10n.selectScene,
                      color: theme.appColors.black,
                      style: theme.textTheme.h30.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    hSpace(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.appColors.grey.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedSceneId.value,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          hintText: l10n.selectScene,
                          hintStyle: theme.textTheme.h30.copyWith(
                            color: theme.appColors.grey,
                            fontSize: 16,
                          ),
                        ),
                        items:
                            sceneIds.map((id) {
                              return DropdownMenuItem<String>(
                                value: id,
                                child: ThemeText(
                                  text: sceneIdToLabel[id]!,
                                  color: theme.appColors.black,
                                  style: theme.textTheme.h30.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (id) {
                          selectedSceneId.value = id;
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: theme.appColors.grey,
                        ),
                        dropdownColor: theme.appColors.background,
                        style: theme.textTheme.h30.copyWith(
                          fontSize: 16,
                          color: theme.appColors.black,
                        ),
                      ),
                    ),
                    hSpace(height: 24),
                    ThemeText(
                      text: l10n.selectDogCondition,
                      color: theme.appColors.black,
                      style: theme.textTheme.h30.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    hSpace(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.appColors.grey.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedConditionId.value,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          hintText: l10n.selectDogCondition,
                          hintStyle: theme.textTheme.h30.copyWith(
                            color: theme.appColors.grey,
                            fontSize: 16,
                          ),
                        ),
                        items:
                            conditionIds.map((id) {
                              return DropdownMenuItem<String>(
                                value: id,
                                child: ThemeText(
                                  text: conditionIdToLabel[id]!,
                                  color: theme.appColors.black,
                                  style: theme.textTheme.h30.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (id) {
                          selectedConditionId.value = id;
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: theme.appColors.grey,
                        ),
                        dropdownColor: theme.appColors.background,
                        style: theme.textTheme.h30.copyWith(
                          fontSize: 16,
                          color: theme.appColors.black,
                        ),
                      ),
                    ),
                    hSpace(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ThemeText(
                        text:
                            purchaseState.isSubscribed
                                ? l10n.generationsUnlimited
                                : l10n.generationsLeft(
                                  generationCount,
                                  l10n.freePlan,
                                ),
                        color: theme.appColors.black,
                        style: theme.textTheme.h30,
                      ),
                    ),
                    hSpace(height: 32),
                    PrimaryButton(
                      text: l10n.generateMusic,
                      screen: 'audio_generation_screen',
                      width: double.infinity,
                      isDisabled:
                          selectedSceneId.value == null ||
                          selectedConditionId.value == null ||
                          musicGenerationState.isLoading,
                      callback: () {
                        if (generationCount > 0) {
                          ref
                              .read(generationCountProvider.notifier)
                              .decrement();
                          final request = MusicGenerationRequest(
                            userId: profile.userId,
                            dogId: profile.id,
                            scenario: selectedSceneId.value!,
                            dogCondition: selectedConditionId.value!,
                            additionalInfo: additionalInfoController.text,
                            dogBreed: profile.breed,
                            dogPersonalityTraits: profile.personalityTraits,
                          );
                          ref
                              .read(
                                musicGenerationStateNotifierProvider.notifier,
                              )
                              .generateMusic(request);
                        } else {
                          // showGenerationLimitDialog(context: context);
                          showGenerationLimitNoticeDialog(context: context);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          if (musicGenerationState.isLoading)
            const ModalBarrier(color: Colors.black54, dismissible: false),
          if (musicGenerationState.isLoading) const Center(child: Loading()),
        ],
      ),
    );
  }
}
