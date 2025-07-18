import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/hook.dart';
import '../import/provider.dart';
import '../import/theme.dart';
import 'l10n/app_localizations.dart';

/// 最初に起動されるウィジェット(アプリ)
class App extends HookConsumerWidget {
  /// インスタンスを作成します
  const App({super.key});

  Future<void> _handleDynamicLinks(WidgetRef ref) async {
    final dynamicLinks = FirebaseDynamicLinks.instance;

    // アプリが起動していない状態でリンクを開いた場合
    final data = await dynamicLinks.getInitialLink();
    if (data != null) {
      final deepLink = data.link;
      // TODO: パスワードを保存するように修正する
      ref.read(authStateNotifierProvider.notifier).signInWithEmailLink(deepLink.toString());
    }

    // アプリが起動中の状態でリンクを開いた場合
    dynamicLinks.onLink.listen((data) {
      final deepLink = data.link;
      ref.read(authStateNotifierProvider.notifier).signInWithEmailLink(deepLink.toString());
    }).onError((error) {
      // Handle error
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final goRouter = ref.watch(goRouterProvider);
    final mediaQuery = ref.watch(mediaQueryStateNotifierProvider);
    final locale = ref.watch(localeProvider);

    useEffect(() {
      _handleDynamicLinks(ref);
      return null;
    }, const []);

    useHandleTransit(context: context, ref: ref);

    return MaterialApp.router(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling, boldText: false),
          child: child!,
        );
      },
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      title: AppLocalizations.of(context)?.productName ?? 'Paw Harmony AI',
      theme: theme.data,
      darkTheme: AppTheme.dark(mediaQuery).data,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja'),
        Locale('en'),
        Locale('fr'),
        Locale('it'),
        Locale('es'),
      ],
    );
  }
}
