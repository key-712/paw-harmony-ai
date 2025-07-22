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

@TypedGoRoute<LoginScreenRoute>(path: '/login')
/// ログイン画面への遷移データクラス
class LoginScreenRoute extends GoRouteData with _$LoginScreenRoute {
  /// ログイン画面への遷移データクラス
  const LoginScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginScreen();
}

@TypedGoRoute<SignUpScreenRoute>(path: '/signup')
/// 新規登録画面への遷移データクラス
class SignUpScreenRoute extends GoRouteData with _$SignUpScreenRoute {
  /// 新規登録画面への遷移データクラス
  const SignUpScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignUpScreen();
}

@TypedGoRoute<PasswordResetScreenRoute>(path: '/password-reset')
/// パスワードリセット画面への遷移データクラス
class PasswordResetScreenRoute extends GoRouteData
    with _$PasswordResetScreenRoute {
  /// パスワードリセット画面への遷移データクラス
  const PasswordResetScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PasswordResetScreen();
}

@TypedGoRoute<EmailSentScreenRoute>(path: '/email-sent')
/// メール送信完了画面への遷移データクラス
class EmailSentScreenRoute extends GoRouteData with _$EmailSentScreenRoute {
  /// メール送信完了画面への遷移データクラス
  const EmailSentScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const EmailSentScreen();
}

@TypedGoRoute<DogProfileScreenRoute>(path: '/dog-profile')
/// 犬プロフィール画面への遷移データクラス
class DogProfileScreenRoute extends GoRouteData with _$DogProfileScreenRoute {
  /// 犬プロフィール画面への遷移データクラス
  const DogProfileScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
  // BaseScreenでScrollControllerを管理するため、ここでは渡さない
  DogProfileScreen(scrollController: ScrollController());
}

@TypedGoRoute<SubscriptionSettingScreenRoute>(path: '/subscription_setting')
/// サブスクリプション設定画面への遷移データクラス
class SubscriptionSettingScreenRoute extends GoRouteData
    with _$SubscriptionSettingScreenRoute {
  /// サブスクリプション設定画面への遷移データクラス
  const SubscriptionSettingScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SubscriptionSettingScreen();
}

@TypedGoRoute<PlayerListRoute>(path: '/player-list')
/// プレイヤーリスト画面への遷移データクラス
class PlayerListRoute extends GoRouteData with _$PlayerListRoute {
  /// プレイヤーリスト画面への遷移データクラス
  const PlayerListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      PlayerListScreen(scrollController: ScrollController());
}

@TypedGoRoute<AudioGenerationScreenRoute>(path: '/audio-generation')
/// 音声生成画面への遷移データクラス
class AudioGenerationScreenRoute extends GoRouteData
    with _$AudioGenerationScreenRoute {
  /// 音声生成画面への遷移データクラス
  const AudioGenerationScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AudioGenerationScreen(scrollController: ScrollController());
}

@TypedGoRoute<MusicDetailRoute>(path: '/music-detail/:musicId')
/// 音楽詳細画面への遷移データクラス
class MusicDetailRoute extends GoRouteData with _$MusicDetailRoute {
  /// 音楽詳細画面への遷移データクラス
  const MusicDetailRoute({required this.musicId});

  /// 音楽アイテムのID
  final String musicId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      MusicDetailScreen(musicId: musicId);
}
