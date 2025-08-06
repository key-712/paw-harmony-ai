// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/model.dart';
import '../import/provider.dart';
import '../import/utility.dart';

/// Firestoreのインスタンスを提供するProvider
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

/// FirebaseStorageのインスタンスを提供するProvider
final firebaseStorageProvider = Provider<FirebaseStorage>(
  (ref) => FirebaseStorage.instance,
);

/// DogProfileのStateNotifier
class DogProfileStateNotifier extends StateNotifier<AsyncValue<DogProfile?>> {
  /// DogProfileStateNotifierのコンストラクタ
  DogProfileStateNotifier(this.ref, this.userId)
    : super(const AsyncValue.loading()) {
    if (userId != null) {
      fetchDogProfile();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  /// RiverpodのRefインスタンス
  final Ref ref;

  /// ユーザーID
  final String? userId;

  /// プロフィール取得メソッド
  Future<void> fetchDogProfile() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final snapshot =
          await ref
              .read(firestoreProvider)
              .collection('dogProfiles')
              .where('user_id', isEqualTo: userId)
              .limit(1)
              .get();
      if (!mounted) {
        logger.d('StateNotifierがアンマウントされたため、処理を中断');
        return;
      }
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        try {
          // Firestoreのデータをそのまま使用（フィールド名マッピングは自動生成コードで処理）
          final convertedData = Map<String, dynamic>.from(data);

          // dateOfBirthがTimestampの場合はDateTimeに変換
          if (convertedData['date_of_birth'] is Timestamp) {
            convertedData['date_of_birth'] =
                (convertedData['date_of_birth'] as Timestamp)
                    .toDate()
                    .toIso8601String();
          }

          // breedが数値の場合は文字列に変換
          if (convertedData['breed'] is int) {
            convertedData['breed'] = convertedData['breed'].toString();
          }

          // personalityTraitsが数値のリストの場合は文字列のリストに変換
          if (convertedData['personality_traits'] is List) {
            final traits = convertedData['personality_traits'] as List;
            convertedData['personality_traits'] =
                traits.map((trait) => trait.toString()).toList();
          }

          final profile = DogProfile.fromJson(convertedData);
          state = AsyncValue.data(profile);
        } on Exception catch (e, st) {
          logger.e('DogProfile.fromJsonでエラー発生: $e', error: e, stackTrace: st);
          state = AsyncValue.error(e, st);
        }
      } else {
        logger.e('プロフィールが見つかりませんでした');
        state = const AsyncValue.data(null);
      }
    } on FirebaseException catch (e, st) {
      logger.e(
        'FirebaseException発生: ${e.code} - ${e.message}',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      // オブジェクトが見つからない場合はエラーではなく、プロフィールがない状態として扱う
      if (e.code == 'object-not-found') {
        logger.d('オブジェクトが見つからないため、nullとして扱います');
        state = const AsyncValue.data(null);
      } else {
        logger.e('FirebaseExceptionをエラーとして設定', error: e, stackTrace: st);
        state = AsyncValue.error(e, st);
      }
    } on Exception catch (e, st) {
      logger.e('一般Exception発生: $e', error: e, stackTrace: st);
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  /// プロフィール作成・更新メソッド
  ///
  /// [profile] 保存するDogProfileインスタンス
  /// [imageFile] アップロードする画像ファイル (任意)
  /// プロフィール作成・更新メソッド
  ///
  /// [profile] 保存するDogProfileインスタンス
  /// [imageFile] アップロードする画像ファイル (任意)
  Future<void> saveDogProfile(DogProfile profile, {File? imageFile}) async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      var imageUrl = profile.profileImageUrl;
      if (imageFile != null) {
        final storageRef = ref.read(firebaseStorageProvider).ref();
        final imageFileName =
            'dog_profiles/${profile.userId}/${profile.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadTask = storageRef.child(imageFileName).putFile(imageFile);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
        logger.d('画像アップロード完了: $imageUrl');
      }

      if (!mounted) return;
      final updatedProfile = profile.copyWith(profileImageUrl: imageUrl);
      await ref
          .read(firestoreProvider)
          .collection('dogProfiles')
          .doc(updatedProfile.id)
          .set(updatedProfile.toJson());
      logger.d('プロフィール保存完了');
      if (!mounted) return;
      state = AsyncValue.data(updatedProfile);
    } on FirebaseException catch (e, st) {
      if (!mounted) return;
      logger.e(
        'Firebaseエラー: ${e.code}, ${e.message}',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
    } on Exception catch (e, st) {
      if (!mounted) return;
      logger.e('一般エラー: $e', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}

/// DogProfileStateNotifierを提供するProvider
final AutoDisposeStateNotifierProvider<
  DogProfileStateNotifier,
  AsyncValue<DogProfile?>
>
dogProfileStateNotifierProvider = StateNotifierProvider.autoDispose<
  DogProfileStateNotifier,
  AsyncValue<DogProfile?>
>((ref) {
  final userId = ref.watch(authStateChangesProvider).value?.uid;
  return DogProfileStateNotifier(ref, userId);
});

/// プロフィールが登録済みかどうかを判定するProvider
///
/// [dogProfileStateNotifierProvider] を監視し、DogProfileオブジェクトが存在すれば登録済みと判断します。
final isProfileRegisteredProvider = Provider<bool>((ref) {
  final dogProfileState = ref.watch(dogProfileStateNotifierProvider);
  return dogProfileState.when(
    data: (profile) => profile != null,
    loading: () => false,
    error: (error, stack) => false,
  );
});
