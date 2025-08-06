import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/utility.dart';

/// FirebaseAuthのインスタンスを提供するProvider
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

/// 認証状態の変更を監視するStreamProvider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// ユーザーがログイン済みかどうかを判定するProvider
///
/// [authStateChangesProvider] を監視し、Userオブジェクトが存在すればログイン済みと判断します。
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (error, stack) => false,
  );
});

/// 認証ロジックを管理するStateNotifier
class AuthStateNotifier extends StateNotifier<AsyncValue<void>> {
  /// AuthStateNotifierのコンストラクタ
  AuthStateNotifier(this.ref) : super(const AsyncValue.data(null));

  /// RiverpodのRefインスタンス
  final Ref ref;

  /// 新規登録を行うメソッド
  ///
  /// [email] ユーザーのメールアドレス
  /// [password] ユーザーのパスワード
  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await ref
          .read(firebaseAuthProvider)
          .createUserWithEmailAndPassword(email: email, password: password);

      // メール確認を送信
      if (credential.user != null) {
        await credential.user!.sendEmailVerification();
      }

      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// ログインを行うメソッド
  ///
  /// [email] ユーザーのメールアドレス
  /// [password] ユーザーのパスワード
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        // ユーザー情報を再読み込みして最新の確認状態を取得
        await credential.user!.reload();

        if (!credential.user!.emailVerified) {
          // メール未確認の場合はエラーを投げるが、ログアウトはしない
          throw FirebaseAuthException(
            code: 'requires-recent-login',
            message: 'Email verification required',
          );
        }
      }

      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// メールアドレスの確認メールを再送信する
  Future<void> sendEmailVerification() async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user is currently signed in',
        );
      }
      await user.sendEmailVerification();
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// メール確認状態をチェックするメソッド
  ///
  /// 戻り値: メール確認済みの場合はtrue、未確認の場合はfalse
  /// 例外: エラーが発生した場合はFirebaseAuthExceptionを投げる
  Future<bool> isEmailVerified() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user is currently signed in',
      );
    }

    try {
      // ユーザー情報を再読み込みして最新の確認状態を取得
      await user.reload();
      return user.emailVerified;
    } on FirebaseAuthException catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  /// メール認証が完了したかチェックして、完了していればログイン状態を更新する
  Future<void> checkEmailVerificationAndUpdateState() async {
    try {
      final isVerified = await isEmailVerified();
      if (isVerified) {
        // メール認証が完了している場合はログイン成功として扱う
        state = const AsyncValue.data(null);
      }
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// パスワードリセットメールを送信するメソッド
  ///
  /// [email] リセットメールを送信するメールアドレス
  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(firebaseAuthProvider).sendPasswordResetEmail(email: email);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// ログアウトを行うメソッド
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(firebaseAuthProvider).signOut();
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// アカウント削除を行うメソッド
  ///
  /// 現在ログインしているユーザーのアカウントを完全に削除します。
  /// この操作は取り消すことができません。
  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user is currently signed in',
        );
      }

      // ユーザーアカウントを削除
      await user.delete();
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// AuthStateNotifierを提供するProvider
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<void>>(
      AuthStateNotifier.new,
    );
