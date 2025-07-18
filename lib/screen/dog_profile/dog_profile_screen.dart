// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../import/component.dart';
import '../../import/model.dart';
import '../../import/provider.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// 犬のプロフィール画面のウィジェット
class DogProfileScreen extends HookConsumerWidget {
  /// DogProfileScreenのコンストラクタ
  const DogProfileScreen({super.key, required this.scrollController});

  /// スクロールコントローラー
  final ScrollController scrollController;

  @override
  /// 犬のプロフィール画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final breedController = useTextEditingController();
    final dateOfBirth = useState<DateTime?>(null);
    final ageController = useTextEditingController();
    final gender = useState<String?>(null);
    final genderError = useState<String?>(null);
    final personalities = useState<Set<String>>({});
    final pickedImage = useState<File?>(null);
    final theme = ref.watch(appThemeProvider);

    final dogProfileState = ref.watch(dogProfileStateNotifierProvider);
    final userId = ref.watch(authStateChangesProvider).value?.uid;

    /// プロフィール保存状態のリスナー（エラーハンドリングのみ）
    ref.listen<AsyncValue<DogProfile?>>(dogProfileStateNotifierProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (err, stack) {
          showAlertSnackBar(
            context: context,
            theme: theme,
            text: l10n.errorOccurred,
          );
        },
      );
    });

    // 既存のプロフィール情報をフォームに設定
    useEffect(() {
      dogProfileState.whenData((profile) {
        if (profile != null) {
          nameController.text = profile.name;
          breedController.text = profile.breed;
          dateOfBirth.value = profile.dateOfBirth;
          ageController.text = profile.age?.toString() ?? '';
          gender.value = profile.gender;
          personalities.value = Set.from(profile.personalityTraits);
          // 既存のプロフィール画像がある場合は表示
          if (profile.profileImageUrl != null) {
            // NetworkImageは直接pickedImage.valueに設定できないため、
            // ここではpickedImage.valueはnullのままにして、
            // CircleAvatarのbackgroundImageでNetworkImageを直接使用する
          }
        }
      });
      return null;
    }, [dogProfileState.value]);

    final dogBreeds = <String>[
      l10n.breedToyPoodle,
      l10n.breedChihuahua,
      l10n.breedShiba,
      l10n.breedMiniatureDachshund,
      l10n.breedPomeranian,
      l10n.breedFrenchBulldog,
      l10n.breedGoldenRetriever,
      l10n.breedLabradorRetriever,
      l10n.breedMix,
      l10n.breedOther,
    ];

    return Scaffold(
      appBar:
          dogProfileState.value == null
              ? BaseHeader(title: l10n.registerDogProfileTitle)
              : BackIconHeader(title: l10n.editDogProfileTitle),
      body: dogProfileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: ThemeText(
                text: l10n.errorOccurred,
                color: theme.appColors.black,
                style: theme.textTheme.h30,
              ),
            ),
        data:
            (profile) => SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            pickedImage.value = File(pickedFile.path);
                          }
                        },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          child:
                              pickedImage.value != null
                                  ? ClipOval(
                                    child: Image.file(
                                      pickedImage.value!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : (profile?.profileImageUrl != null
                                      ? ClipOval(
                                        child: Image.network(
                                          profile!.profileImageUrl!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            // 画像ロード失敗時の代替ウィジェット
                                            return Icon(
                                              Icons.broken_image,
                                              color: Colors.grey[800],
                                              size: 40,
                                            );
                                          },
                                        ),
                                      )
                                      : Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey[800],
                                        size: 40,
                                      )),
                        ),
                      ),
                    ),
                    hSpace(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: l10n.dogName),
                      validator:
                          (value) =>
                              value!.isEmpty ? l10n.dogNameValidator : null,
                    ),
                    DropdownButtonFormField<String>(
                      value:
                          breedController.text.isEmpty
                              ? null
                              : breedController.text,
                      decoration: InputDecoration(labelText: l10n.dogBreed),
                      items:
                          dogBreeds
                              .map(
                                (b) => DropdownMenuItem(
                                  value: b,
                                  child: ThemeText(
                                    text: b,
                                    color: theme.appColors.black,
                                    style: theme.textTheme.h30,
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          breedController.text = value;
                        }
                      },
                      validator:
                          (value) =>
                              value == null ? l10n.dogBreedValidator : null,
                    ),
                    hSpace(height: 16),
                    ListTile(
                      title: ThemeText(
                        text:
                            dateOfBirth.value == null
                                ? l10n.selectDateOfBirth
                                : l10n.dateOfBirth(
                                  dateOfBirth.value!
                                      .toLocal()
                                      .toIso8601String()
                                      .split('T')[0],
                                ),
                        color: theme.appColors.black,
                        style: theme.textTheme.h30,
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: dateOfBirth.value ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (selectedDate != null) {
                          dateOfBirth.value = selectedDate;
                          // 年齢を自動計算
                          final now = DateTime.now();
                          final age =
                              now.year -
                              selectedDate.year -
                              (now.month < selectedDate.month ||
                                      (now.month == selectedDate.month &&
                                          now.day < selectedDate.day)
                                  ? 1
                                  : 0);
                          ageController.text = age.toString();
                        }
                      },
                    ),

                    /// 年齢入力フィールド
                    /// 生年月日が選択されている場合は自動計算され、編集不可
                    TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(labelText: l10n.age),
                      keyboardType: TextInputType.number,
                      readOnly: true, // 年齢は常に編集不可
                      contextMenuBuilder: (context, editableTextState) {
                        // コンテキストメニューを無効化
                        return const SizedBox.shrink();
                      },
                      validator: (value) {
                        return null; // 年齢は生年月日からの自動計算のため、バリデーションは不要
                      },
                    ),
                    hSpace(height: 16),
                    ThemeText(
                      text: l10n.gender,
                      color: theme.appColors.black,
                      style: theme.textTheme.h30,
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'male',
                          groupValue: gender.value,
                          onChanged: (value) {
                            gender.value = value;
                            genderError.value = null;
                          },
                        ),
                        ThemeText(
                          text: l10n.male,
                          color: theme.appColors.black,
                          style: theme.textTheme.h30,
                        ),
                        Radio<String>(
                          value: 'female',
                          groupValue: gender.value,
                          onChanged: (value) {
                            gender.value = value;
                            genderError.value = null;
                          },
                        ),
                        ThemeText(
                          text: l10n.female,
                          color: theme.appColors.black,
                          style: theme.textTheme.h30,
                        ),
                      ],
                    ),
                    if (genderError.value != null)
                      ThemeText(
                        text: genderError.value!,
                        color: theme.appColors.error,
                        style: theme.textTheme.h30,
                      ),
                    hSpace(height: 16),
                    ThemeText(
                      text: l10n.personality,
                      color: theme.appColors.black,
                      style: theme.textTheme.h30,
                    ),
                    MultiSelectChip(
                      choices: [
                        l10n.personalityEasygoing,
                        l10n.personalityActive,
                        l10n.personalityTimid,
                        l10n.personalitySociable,
                        l10n.personalityAffectionate,
                        l10n.personalityMyPace,
                      ],
                      selectedChoices: personalities.value.toList(),
                      onSelectionChanged: (selectedList) {
                        personalities.value = Set.from(selectedList);
                      },
                    ),
                    hSpace(height: 32),
                    PrimaryButton(
                      text: profile == null ? l10n.register : l10n.update,
                      screen: 'dog_profile_screen',
                      width: double.infinity,
                      isDisabled: false,
                      callback: () async {
                        if (formKey.currentState!.validate()) {
                          if (gender.value == null) {
                            genderError.value = l10n.genderValidator;
                            return;
                          }
                          if (userId != null) {
                            final newProfile = DogProfile(
                              id: profile?.id ?? const Uuid().v4(),
                              userId: userId,
                              name: nameController.text,
                              breed: breedController.text,
                              dateOfBirth: dateOfBirth.value,
                              age: int.tryParse(ageController.text),
                              gender: gender.value!,
                              personalityTraits: personalities.value.toList(),
                              profileImageUrl: profile?.profileImageUrl,
                            );
                            await ref
                                .read(dogProfileStateNotifierProvider.notifier)
                                .saveDogProfile(
                                  newProfile,
                                  imageFile: pickedImage.value,
                                );
                            if (context.mounted) {
                              showSnackBar(
                                context: context,
                                theme: theme,
                                text: l10n.profileSaved,
                              );
                              // 新規登録の場合はホーム画面へ、編集の場合は前の画面に戻る
                              if (profile == null) {
                                const BaseScreenRoute().go(context);
                              } else {
                                GoRouter.of(context).pop();
                              }
                            }
                          }
                        }
                      },
                    ),
                    if (profile != null) // 編集画面の場合のみキャンセルボタンを表示
                      hSpace(height: 16),
                    CancelButton(
                      text: l10n.cancel,
                      screen: 'dog_profile_screen',
                      width: double.infinity,
                      isDisabled: false,
                      callback: () {
                        if (context.mounted) {
                          GoRouter.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
