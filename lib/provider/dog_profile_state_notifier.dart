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
    state = const AsyncValue.loading();
    logger.d('プロフィール取得開始: userId = $userId');
    try {
      final snapshot =
          await ref
              .read(firestoreProvider)
              .collection('dogProfiles')
              .where('user_id', isEqualTo: userId) // 'userId' を 'user_id' に修正
              .limit(1)
              .get();
      if (snapshot.docs.isNotEmpty) {
        state = AsyncValue.data(
          DogProfile.fromJson(snapshot.docs.first.data()),
        );
      } else {
        state = const AsyncValue.data(null);
      }
    } on FirebaseException catch (e, st) {
      // オブジェクトが見つからない場合はエラーではなく、プロフィールがない状態として扱う
      if (e.code == 'object-not-found') {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(e, st);
      }
    } on Exception catch (e, st) {
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
    state = const AsyncValue.loading();
    try {
      var imageUrl = profile.profileImageUrl;
      if (imageFile != null) {
        logger.d('画像をアップロード中...');
        final storageRef = ref.read(firebaseStorageProvider).ref();
        final imageFileName =
            'dog_profiles/${profile.userId}/${profile.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadTask = storageRef.child(imageFileName).putFile(imageFile);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
        logger.d('画像アップロード完了: $imageUrl');
      }

      final updatedProfile = profile.copyWith(profileImageUrl: imageUrl);
      logger.d('Firestoreにプロフィールを保存中: ${updatedProfile.toJson()}');
      await ref
          .read(firestoreProvider)
          .collection('dogProfiles')
          .doc(updatedProfile.id)
          .set(updatedProfile.toJson());
      logger.d('プロフィール保存完了');
      state = AsyncValue.data(updatedProfile);
    } on FirebaseException catch (e, st) {
      logger.e(
        'Firebaseエラー: ${e.code}, ${e.message}',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
    } on Exception catch (e, st) {
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
