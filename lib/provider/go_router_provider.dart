import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/route.dart';
import '../import/utility.dart';

/// GoRouterのインスタンスを管理するプロバイダ
final goRouterProvider = Provider<GoRouter>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isInitialLaunch =
        prefs.getBool(SharedPreferencesKeys.initialLaunchKey) ?? true;
    if (isInitialLaunch) {
      prefs.setBool(SharedPreferencesKeys.initialLaunchKey, false);
    }
    final initialLocation = isInitialLaunch
        ? const BaseScreenRoute().location
        // : const WalkThroughRoute().location
        : const BaseScreenRoute().location;

    return GoRouter(
      initialLocation: initialLocation,
      routes: $appRoutes,
    );
  },
);
