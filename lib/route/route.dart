import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../import/screen.dart';

part 'route.g.dart';

@TypedGoRoute<WalkThroughRoute>(path: '/walk-through')
/// ウォークスルー画面への遷移データクラス
class WalkThroughRoute extends GoRouteData with _$WalkThroughRoute {
  /// ウォークスルー画面への遷移データクラス
  const WalkThroughRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const WalkThroughScreen();
}

@TypedGoRoute<BaseScreenRoute>(path: '/base')
/// ベース画面への遷移データクラス
class BaseScreenRoute extends GoRouteData with _$BaseScreenRoute {
  /// ベース画面への遷移データクラス
  const BaseScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const BaseScreen();
}

@TypedGoRoute<PushScreenRoute>(path: '/push')
/// Push通知機能についての案内ページ(ウォークスルーの構成ページ)への遷移データクラス
class PushScreenRoute extends GoRouteData with _$PushScreenRoute {
  /// Push通知機能についての案内ページ(ウォークスルーの構成ページ)への遷移データクラス
  const PushScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const PushScreen();
}

@TypedGoRoute<ContactScreenRoute>(path: '/contact')
/// お問い合わせ画面への遷移データクラス
class ContactScreenRoute extends GoRouteData with _$ContactScreenRoute {
  /// お問い合わせ画面への遷移データクラス
  const ContactScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ContactScreen();
}

@TypedGoRoute<RequestScreenRoute>(path: '/request')
/// ご意見・ご要望画面への遷移データクラス
class RequestScreenRoute extends GoRouteData with _$RequestScreenRoute {
  /// ご意見・ご要望画面への遷移データクラス
  const RequestScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RequestScreen();
}

@TypedGoRoute<RecommendAppScreenRoute>(path: '/recommend-app')
/// その他のオススメアプリ画面への遷移データクラス
class RecommendAppScreenRoute extends GoRouteData
    with _$RecommendAppScreenRoute {
  /// その他のオススメアプリ画面への遷移データクラス
  const RecommendAppScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RecommendAppScreen();
}

@TypedGoRoute<LanguageSettingScreenRoute>(path: '/language-setting')
/// 言語設定画面への遷移データクラス
class LanguageSettingScreenRoute extends GoRouteData
    with _$LanguageSettingScreenRoute {
  /// 言語設定画面への遷移データクラス
  const LanguageSettingScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LanguageSettingScreen();
}

@TypedGoRoute<SettingScreenRoute>(path: '/settings')
/// 設定画面への遷移データクラス
class SettingScreenRoute extends GoRouteData with _$SettingScreenRoute {
  /// 設定画面への遷移データクラス
  const SettingScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SettingScreen(scrollController: ScrollController());
}
