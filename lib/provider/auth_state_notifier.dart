import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
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
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://flutter-tips-8dc02.firebaseapp.com', // TODO: Replace with your domain
        handleCodeInApp: true,
        iOSBundleId: 'com.example.flutter_tips', // TODO: Replace with your bundle id
        androidPackageName: 'com.example.flutter_tips', // TODO: Replace with your package name
        androidInstallApp: true,
        androidMinimumVersion: '12',
      );

      await ref
          .read(firebaseAuthProvider)
          .sendSignInLinkToEmail(email: email, actionCodeSettings: actionCodeSettings);
      await ref.read(sharedPreferencesProvider).setString(SharedPreferencesKeys.email, email);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithEmailLink(String emailLink) async {
    state = const AsyncValue.loading();
    try {
      final email = ref.read(sharedPreferencesProvider).getString(SharedPreferencesKeys.email);
      if (email == null) {
        throw Exception('Email is not set');
      }
      await ref
          .read(firebaseAuthProvider)
          .signInWithEmailLink(email: email, emailLink: emailLink);
      await ref.read(sharedPreferencesProvider).remove(SharedPreferencesKeys.email);
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
