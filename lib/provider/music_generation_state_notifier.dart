// ignore_for_file: unawaited_futures, lines_longer_than_80_chars

import 'dart:async'; // Completerのために追加
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart'; // Add this import back
import 'package:webview_flutter/webview_flutter.dart';

import '../import/model.dart';
import '../import/provider.dart';
import '../import/utility.dart';

/// 音楽生成のStateNotifier
class MusicGenerationStateNotifier
    extends StateNotifier<AsyncValue<MusicGenerationHistory?>> {
  /// MusicGenerationStateNotifierのコンストラクタ
  MusicGenerationStateNotifier(this.ref) : super(const AsyncValue.data(null));

  /// RiverpodのRefインスタンス
  final Ref ref;

  // Store the current request to use when music generation completes
  MusicGenerationRequest? _currentRequest; // Declare as class member

  /// 音楽生成メソッド
  ///
  /// [request] 音楽生成リクエスト
  /// [controller] WebViewのコントローラー
  Future<void> generateMusic(
    MusicGenerationRequest request,
    WebViewController controller,
  ) async {
    logger
      ..d('=== 音楽生成リクエスト開始 ===')
      ..d('リクエスト情報:')
      ..d('  - dogBreed: ${request.dogBreed}')
      ..d('  - dogPersonalityTraits: ${request.dogPersonalityTraits}')
      ..d('  - scenario: ${request.scenario}');

    state = const AsyncValue.loading();
    _currentRequest = request; // Store the request
    try {
      final jsonString = jsonEncode({
        'dogBreed': request.dogBreed,
        'dogPersonalityTraits': request.dogPersonalityTraits,
        'scenario': request.scenario,
      });

      logger
        ..d('送信するJSONデータ: $jsonString')
        ..d('WebViewにJavaScriptを実行中...');

      await controller.runJavaScript(
        'window.postMessage({ type: "generateMusic", payload: $jsonString }, "*");',
      );

      logger.d('JavaScript実行完了');
    } on Exception catch (e, st) {
      logger.e('音楽生成エラー', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// 音楽生成が完了したときに呼び出されるメソッド
  Future<void> musicGenerationCompleted(String message) async {
    logger.d('=== 音楽生成完了処理開始 ===');

    if (_currentRequest == null) {
      logger.e('音楽生成リクエストが見つかりません。');
      state = AsyncValue.error(
        Exception('音楽生成リクエストが見つかりません。'),
        StackTrace.current,
      );
      return;
    }

    logger
      ..d('現在のリクエスト情報:')
      ..d('  - userId: ${_currentRequest!.userId}')
      ..d('  - dogId: ${_currentRequest!.dogId}')
      ..d('  - scenario: ${_currentRequest!.scenario}')
      ..d('  - dogCondition: ${_currentRequest!.dogCondition}')
      ..d('  - dogBreed: ${_currentRequest!.dogBreed}');

    try {
      // JSONメッセージをパース
      final jsonData = jsonDecode(message) as Map<String, dynamic>;
      final base64MusicData = jsonData['data'] as String;

      logger
        ..d('音楽データを受信しました。Base64データの長さ: ${base64MusicData.length}')
        ..d('Base64データの先頭50文字: ${base64MusicData.substring(0, 50)}...');

      // Base64データをデコードしてFirebase Storageにアップロード
      final musicBytes = base64Decode(
        base64MusicData.split(',')[1],
      ); // "data:audio/wav;base64,..." のヘッダを除去

      logger.d('音楽データをデコードしました。バイト数: ${musicBytes.length}');

      final fileName = 'generated_music/${const Uuid().v4()}.wav';
      final storageRef = ref
          .read(firebaseStorageProvider)
          .ref()
          .child(fileName);

      logger.d('Firebase Storageにアップロード中: $fileName');
      await storageRef.putData(musicBytes);
      final musicUrl = await storageRef.getDownloadURL();

      logger.d('音楽URLを取得しました: $musicUrl');

      final historyId = const Uuid().v4();
      logger.d('生成された履歴ID: $historyId');

      final newHistory = MusicGenerationHistory(
        id: historyId,
        userId: _currentRequest!.userId,
        dogId: _currentRequest!.dogId,
        scenario: _currentRequest!.scenario,
        dogCondition: _currentRequest!.dogCondition,
        generatedMusicUrl: musicUrl,
        duration: 8, // 実際の音楽生成時間（8秒）
        createdAt: DateTime.now(),
        dogBreed: _currentRequest!.dogBreed,
        dogPersonalityTraits: _currentRequest!.dogPersonalityTraits,
      );

      logger
        ..d('作成された履歴オブジェクト:')
        ..d('  - id: ${newHistory.id}')
        ..d('  - userId: ${newHistory.userId}')
        ..d('  - dogId: ${newHistory.dogId}')
        ..d('  - scenario: ${newHistory.scenario}')
        ..d('  - generatedMusicUrl: ${newHistory.generatedMusicUrl}')
        ..d('  - createdAt: ${newHistory.createdAt}')
        // Save to history
        ..d('音楽生成履歴をFirestoreに保存中: ${newHistory.id}')
        ..d('Firestoreコレクション: musicGenerationHistories')
        ..d('ドキュメントID: ${newHistory.id}');

      final firestore = ref.read(firestoreProvider);
      logger.d('Firestoreインスタンス取得完了');

      final collectionRef = firestore.collection('musicGenerationHistories');
      logger.d('コレクション参照取得完了');

      final docRef = collectionRef.doc(newHistory.id);
      logger.d('ドキュメント参照取得完了');

      final historyJson = newHistory.toJson();
      logger
        ..d('履歴JSON変換完了: ${historyJson.keys}')
        ..d('送信するJSONデータ: $historyJson');

      await docRef.set(historyJson);
      logger.d('Firestoreへの保存完了');

      state = AsyncValue.data(newHistory);
      _currentRequest = null; // Clear the request

      logger.d('=== 音楽生成完了処理終了 ===');
    } on Exception catch (e, st) {
      logger.e('音楽生成完了処理エラー', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// 音楽生成が失敗したときに呼び出されるメソッド
  void musicGenerationFailed(String errorMessage) {
    logger.e('音楽生成失敗: $errorMessage');
    state = AsyncValue.error(
      Exception('音楽の生成に失敗しました: $errorMessage'),
      StackTrace.current,
    );
    _currentRequest = null; // Clear the request
  }
}

/// MusicGenerationStateNotifierを提供するProvider
final AutoDisposeStateNotifierProvider<
  MusicGenerationStateNotifier,
  AsyncValue<MusicGenerationHistory?>
>
musicGenerationStateNotifierProvider = StateNotifierProvider.autoDispose<
  MusicGenerationStateNotifier,
  AsyncValue<MusicGenerationHistory?>
>(MusicGenerationStateNotifier.new);

/// 音楽生成履歴を取得するStreamProvider
final AutoDisposeStreamProvider<List<MusicGenerationHistory>>
musicHistoryStreamProvider = StreamProvider.autoDispose<
  List<MusicGenerationHistory>
>((ref) {
  final userId = ref.watch(authStateChangesProvider).value?.uid;
  logger
    ..d('=== 音楽履歴取得開始 ===')
    ..d('ユーザーID: $userId')
    ..d(
      'authStateChangesProvider.value: ${ref.watch(authStateChangesProvider).value}',
    )
    ..d(
      'authStateChangesProvider.value?.uid: ${ref.watch(authStateChangesProvider).value?.uid}',
    );

  if (userId == null) {
    logger.d('ユーザーIDがnullのため、空のリストを返します');
    return Stream.value([]);
  }

  try {
    logger.d('Firestoreインスタンスを取得中...');
    final firestore = ref.read(firestoreProvider);
    logger
      ..d('Firestoreインスタンス取得完了')
      ..d('コレクション参照を取得中...');
    final collectionRef = firestore.collection('musicGenerationHistories');
    logger
      ..d('コレクション参照取得完了: musicGenerationHistories')
      ..d('クエリを構築中...');

    // ユーザーIDでフィルタリング
    final query = collectionRef.where('user_id', isEqualTo: userId);

    logger
      ..d('クエリ構築完了: ユーザーID $userId でフィルタリング')
      ..d('スナップショットストリームを開始...');
    return query
        .snapshots()
        .map((snapshot) {
          logger.d('スナップショット受信: ${snapshot.docs.length}件のドキュメント');

          final historyList =
              snapshot.docs
                  .map((doc) {
                    logger
                      ..d('ドキュメント処理中: ${doc.id}')
                      ..d('ドキュメントデータ: ${doc.data().keys}')
                      ..d('ドキュメントのuser_id: ${doc.data()['user_id']}')
                      ..d('現在のユーザーID: $userId')
                      ..d('ドキュメントの全データ: ${doc.data()}');

                    try {
                      final history = MusicGenerationHistory.fromJson(
                        doc.data(),
                      );
                      logger
                        ..d('履歴オブジェクト作成完了: ${history.id}')
                        ..d('履歴のuserId: ${history.userId}')
                        ..d(
                          'ユーザーID比較: "${history.userId}" == "$userId" = ${history.userId == userId}',
                        );
                      return history;
                    } on Exception catch (e) {
                      logger.e('ドキュメントのパースエラー: ${doc.id}', error: e);
                      return null;
                    }
                  })
                  .where((history) => history != null)
                  .cast<MusicGenerationHistory>()
                  .where((history) {
                    final matches = history.userId == userId;
                    logger.d(
                      'フィルタリング結果: ${history.userId} == $userId = $matches',
                    );
                    return matches;
                  }) // クライアントサイドでフィルタリング
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 最新順にソート

          logger
            ..d('音楽履歴を取得しました: ${historyList.length}件')
            ..d('=== 音楽履歴取得完了 ===');
          return historyList;
        })
        .handleError((Object error, StackTrace stackTrace) {
          // Firestoreの権限エラーが発生した場合、空のリストを返し、エラーをログに記録します。
          // これにより、アプリがクラッシュするのを防ぎますが、
          // 履歴機能はFirestoreのルールが修正されるまで機能しません。
          logger.e(
            'Failed to fetch music history due to permission error',
            error: error,
            stackTrace: stackTrace,
          );
          return <MusicGenerationHistory>[];
        });
  } on Exception catch (e, st) {
    logger.e(
      'An unexpected error occurred while fetching music history',
      error: e,
      stackTrace: st,
    );
    return Stream.value([]);
  }
});
