import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      if (credential.user != null && !credential.user!.emailVerified) {
        throw FirebaseAuthException(code: 'email-not-verified');
      }
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// メールアドレスの確認メールを再送信する
  Future<void> sendEmailVerification() async {
    try {
      await ref.read(firebaseAuthProvider).currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// メール確認状態をチェックするメソッド
  Future<bool> isEmailVerified() async {
    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user != null) {
        // ユーザー情報を再読み込みして最新の確認状態を取得
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
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
}

/// AuthStateNotifierを提供するProvider
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<void>>(
      AuthStateNotifier.new,
    );
