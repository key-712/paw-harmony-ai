import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/route.dart';
import '../import/utility.dart';

/// GoRouterのインスタンスを管理するプロバイダ
final goRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final isInitialLaunch =
      prefs.getBool(SharedPreferencesKeys.initialLaunchKey) ?? true;

  // 初回起動フラグの変更を監視
  ref.listen(sharedPreferencesProvider, (_, prefs) {
    // フラグの変更を検知した場合の処理
  });

  // 初回起動時の初期ロケーションを設定
  final initialLocation =
      isInitialLaunch
          ? const WalkThroughRoute().location
          : ref.watch(isLoggedInProvider)
          ? ref.watch(isProfileRegisteredProvider)
              ? const BaseScreenRoute().location
              : const DogProfileScreenRoute().location
          : const LoginScreenRoute().location;

  return GoRouter(
    initialLocation: initialLocation,
    routes: $appRoutes,
    redirect: (context, state) {
      final isDogProfileLoading =
          ref.watch(dogProfileStateNotifierProvider).isLoading;

      // ユーザーがアクセスしようとしているパス
      final currentPath = state.matchedLocation;

      // プロフィール情報がロード中の場合、リダイレクトを一時停止
      // ただし、ログイン画面やウォークスルー画面など、ロード状態に関わらず表示すべき画面への遷移は許可
      final isGoingToLoginRelated =
          currentPath == const LoginScreenRoute().location ||
          currentPath == const SignUpScreenRoute().location ||
          currentPath == const PasswordResetScreenRoute().location;

      if (isDogProfileLoading) {
        if (isGoingToLoginRelated ||
            currentPath == const WalkThroughRoute().location) {
          return null; // ログイン関連画面やウォークスルー画面への遷移は許可
        }
        // プロフィールロード中は他の画面へのリダイレクトを一時停止
        return null;
      }

      // 初回起動時の処理
      if (isInitialLaunch) {
        // 初回起動時は、ウォークスルー画面以外の画面にアクセスしようとした場合、
        // ウォークスルー画面にリダイレクト
        // ただし、ログイン関連画面への遷移は許可する
        if (currentPath != const WalkThroughRoute().location &&
            !isGoingToLoginRelated) {
          return const WalkThroughRoute().location;
        }
        // ウォークスルー画面にいる場合は何もしない
        return null;
      }

      // 初回起動以外の場合、ウォークスルー画面へのアクセスを禁止
      if (currentPath == const WalkThroughRoute().location) {
        // ログイン済みの場合はベース画面へ、未ログインの場合はログイン画面へ
        return ref.watch(isLoggedInProvider)
            ? const BaseScreenRoute().location
            : const LoginScreenRoute().location;
      }

      // ログイン状態のチェック
      // ログインが必要な画面へのアクセスで、未ログインの場合
      if (!ref.watch(isLoggedInProvider) && !isGoingToLoginRelated) {
        return const LoginScreenRoute().location;
      }

      // ログイン済みの場合のプロフィール登録状態のチェック
      if (ref.watch(isLoggedInProvider)) {
        if (!ref.watch(isProfileRegisteredProvider)) {
          // プロフィールが未登録の場合、DogProfileRouteへ
          // ただし、既にDogProfileRouteにいる場合はリダイレクトしない
          if (currentPath == const DogProfileScreenRoute().location) {
            return null;
          }
          return const DogProfileScreenRoute().location;
        }

        // ログイン済みでプロフィール登録済みの場合
        // ログイン関連画面にいる場合はBaseScreenRouteへリダイレクト
        if (isGoingToLoginRelated) {
          return const BaseScreenRoute().location;
        }
      }

      // それ以外のケースではリダイレクトしない
      return null;
    },
  );
});
