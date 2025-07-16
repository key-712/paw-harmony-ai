import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/model.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final dogProfile = ref.watch(dogProfileStateNotifierProvider);
    final selectedScene = useState<String?>(null);
    final selectedCondition = useState<String?>(null);
    final additionalInfoController = useTextEditingController();
    final purchaseState = ref.watch(purchaseStateNotifierProvider);
    final theme = ref.watch(appThemeProvider);
    final musicGenerationState = ref.watch(
      musicGenerationStateNotifierProvider,
    );

    ref.listen<AsyncValue<MusicGenerationHistory?>>(
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

    final scenes = [
      l10n.sceneLeavingHome,
      l10n.sceneBedtime,
      l10n.sceneStressful,
      l10n.sceneLongDistanceTravel,
      l10n.sceneDailyHealing,
      l10n.sceneCare,
    ];
    final conditions = [
      l10n.conditionCalmDown,
      l10n.conditionRelax,
      l10n.conditionSuppressExcitement,
      l10n.conditionReassure,
      l10n.conditionGoodSleep,
    ];

    return Scaffold(
      appBar: BaseHeader(title: l10n.aiMusicGenerateTitle),
      body: Stack(
        children: [
          dogProfile.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: ThemeText(
                text: l10n.errorOccurred(err.toString()),
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
                    SingleSelectChip(
                      choices: scenes,
                      selectedChoice: selectedScene.value,
                      onSelectionChanged: (selected) {
                        selectedScene.value = selected;
                      },
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
                      decoration: InputDecoration(
                        labelText: l10n.otherOptional,
                        hintText: l10n.otherHint,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    hSpace(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ThemeText(
                        text: purchaseState.isSubscribed
                            ? l10n.generationsUnlimited
                            : l10n.generationsLeft(3, l10n.freePlan),
                        color: theme.appColors.grey,
                        style: theme.textTheme.h30.copyWith(fontSize: 14),
                      ),
                    ),
                    hSpace(height: 32),
                    PrimaryButton(
                      text: l10n.generateMusic,
                      screen: 'ai_music_generate_screen',
                      width: double.infinity,
                      isDisabled: selectedScene.value == null ||
                          selectedCondition.value == null ||
                          musicGenerationState.isLoading,
                      callback: () {
                        final request = MusicGenerationRequest(
                          userId: profile.userId,
                          dogId: profile.id,
                          scenario: selectedScene.value!,
                          dogCondition: selectedCondition.value!,
                          additionalInfo: additionalInfoController.text,
                          dogBreed: profile.breed,
                          dogPersonalityTraits: profile.personalityTraits,
                        );
                        ref
                            .read(
                              musicGenerationStateNotifierProvider.notifier,
                            )
                            .generateMusic(request);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          if (musicGenerationState.isLoading)
            const ModalBarrier(
              color: Colors.black54,
              dismissible: false,
            ),
          if (musicGenerationState.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
