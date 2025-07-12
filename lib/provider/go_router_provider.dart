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
  if (isInitialLaunch) {
    prefs.setBool(SharedPreferencesKeys.initialLaunchKey, false);
  }
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
        return null; // それ以外の画面へのリダイレクトは一時停止
      }

      // ウォークスルーがまだ表示されていない場合、ウォークスルーへ
      // ただし、既にウォークスルー画面にいる場合はリダイレクトしない
      if (isInitialLaunch && currentPath != const WalkThroughRoute().location) {
        return const WalkThroughRoute().location;
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
        // ログイン関連画面やウォークスルー画面にいる場合はBaseScreenRouteへリダイレクト
        if (isGoingToLoginRelated ||
            currentPath == const WalkThroughRoute().location) {
          return const BaseScreenRoute().location;
        }
      }

      // それ以外のケースではリダイレクトしない
      return null;
    },
  );
});
