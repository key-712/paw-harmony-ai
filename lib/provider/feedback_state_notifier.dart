import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../import/model.dart';
import '../import/provider.dart';

/// フィードバック状態を管理するStateNotifier
class FeedbackStateNotifier extends StateNotifier<AsyncValue<void>> {
  /// FeedbackStateNotifierのコンストラクタ
  FeedbackStateNotifier(this.ref) : super(const AsyncValue.data(null));

  /// RiverpodのRefインスタンス
  final Ref ref;

  /// フィードバックを送信するメソッド
  ///
  /// [userId] ユーザーID
  /// [dogId] 犬のID
  /// [musicHistoryId] 音楽履歴ID
  /// [rating] 評価（1-5）
  /// [behaviorTags] 行動タグのリスト
  /// [comment] コメント（オプション）
  Future<void> submitFeedback({
    required String userId,
    required String dogId,
    required String musicHistoryId,
    required int rating,
    required List<String> behaviorTags,
    String? comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      final newFeedback = Feedback(
        id: const Uuid().v4(),
        userId: userId,
        dogId: dogId,
        musicHistoryId: musicHistoryId,
        rating: rating,
        behaviorTags: behaviorTags,
        comment: comment,
        createdAt: DateTime.now(),
      );
      await ref
          .read(firestoreProvider)
          .collection('feedbacks')
          .doc(newFeedback.id)
          .set(newFeedback.toJson());
      state = const AsyncValue.data(null);
    } on FirebaseException catch (e, st) {
      state = AsyncValue.error(e, st);
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// FeedbackStateNotifierを提供するProvider
final AutoDisposeStateNotifierProvider<FeedbackStateNotifier, AsyncValue<void>>
feedbackStateNotifierProvider =
    StateNotifierProvider.autoDispose<FeedbackStateNotifier, AsyncValue<void>>(
      FeedbackStateNotifier.new,
    );

/// 特定の音楽履歴に対するフィードバックを取得するStreamProvider
final AutoDisposeStreamProviderFamily<List<Feedback>, String>
feedbackStreamProvider = StreamProvider.autoDispose
    .family<List<Feedback>, String>((ref, musicHistoryId) {
      return ref
          .read(firestoreProvider)
          .collection('feedbacks')
          .where('musicHistoryId', isEqualTo: musicHistoryId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => Feedback.fromJson(doc.data()))
                    .toList(),
          );
    });
