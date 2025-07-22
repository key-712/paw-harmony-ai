import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/model.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// 音声生成画面のウィジェット
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
      l10n.sceneThunderFireworks,
      l10n.sceneSeparationAnxiety,
      l10n.sceneNewEnvironment,
      l10n.scenePostExercise,
      l10n.sceneGrooming,
      l10n.sceneMealTime,
      l10n.scenePlayTime,
      l10n.sceneTraining,
      l10n.sceneGuests,
      l10n.sceneBadWeather,
      l10n.sceneSeasonalChange,
      l10n.scenePuppySocialization,
      l10n.sceneSeniorCare,
      l10n.sceneMultipleDogs,
      l10n.sceneVetVisit,
    ];
    final conditions = [
      l10n.conditionCalmDown,
      l10n.conditionRelax,
      l10n.conditionSuppressExcitement,
      l10n.conditionReassure,
      l10n.conditionGoodSleep,
      l10n.conditionConcentration,
      l10n.conditionSocialization,
      l10n.conditionLearning,
      l10n.conditionExercise,
      l10n.conditionAppetite,
      l10n.conditionPainRelief,
      l10n.conditionAnxietyRelief,
      l10n.conditionStressRelief,
      l10n.conditionImmunity,
      l10n.conditionMemory,
      l10n.conditionEmotionalStability,
      l10n.conditionCuriosity,
      l10n.conditionPatience,
      l10n.conditionCooperation,
      l10n.conditionIndependence,
      l10n.conditionLove,
    ];

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
                        value: selectedScene.value,
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
                            scenes.map((String scene) {
                              return DropdownMenuItem<String>(
                                value: scene,
                                child: ThemeText(
                                  text: scene,
                                  color: theme.appColors.black,
                                  style: theme.textTheme.h30.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          selectedScene.value = newValue;
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
                        value: selectedCondition.value,
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
                            conditions.map((String condition) {
                              return DropdownMenuItem<String>(
                                value: condition,
                                child: ThemeText(
                                  text: condition,
                                  color: theme.appColors.black,
                                  style: theme.textTheme.h30.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          selectedCondition.value = newValue;
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
                                : l10n.generationsLeft(3, l10n.freePlan),
                        color: theme.appColors.grey,
                        style: theme.textTheme.h30.copyWith(fontSize: 14),
                      ),
                    ),
                    hSpace(height: 32),
                    PrimaryButton(
                      text: l10n.generateMusic,
                      screen: 'audio_generation_screen',
                      width: double.infinity,
                      isDisabled:
                          selectedScene.value == null ||
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
                            .read(musicGenerationStateNotifierProvider.notifier)
                            .generateMusic(request);
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
