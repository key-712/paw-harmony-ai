// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/provider.dart'; // Add this import
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// 音楽生成中のWebViewを表示するダイアログ
class MusicGenerationWebViewDialog extends HookConsumerWidget {
  /// MusicGenerationWebViewDialogのコンストラクタ
  const MusicGenerationWebViewDialog({
    super.key,
    required this.controller,
    required this.onWebViewCreated,
    required this.htmlContent,
  });

  /// WebViewのコントローラー
  final WebViewController controller;

  /// WebViewが作成されたときに呼び出されるコールback
  final ValueChanged<WebViewController> onWebViewCreated;

  /// ロードするHTMLコンテンツ
  final String htmlContent;

  @override
  /// ダイアログを構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    logger.d('MusicGenerationWebViewDialog: build called');
    final theme = ref.watch(appThemeProvider);
    final isInitialized = useRef(false);
    final isLoadingRef = useRef(true);

    // WebViewの初期化を一度だけ実行（useMemoizedを使用）
    final initializedController = useMemoized(() {
      if (isInitialized.value) return controller;

      logger.d('Initializing WebView...');

      // 初期化フラグを先に設定
      isInitialized.value = true;

      // WebViewの初期化を実行
      controller
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (!context.mounted) return;
              logger.d('WebView onPageStarted: $url');
              isLoadingRef.value = true;
              // 状態変更を無効化して再ビルドを防ぐ
            },
            onPageFinished: (String url) {
              if (!context.mounted) return;
              logger.d('WebView onPageFinished: $url');
              isLoadingRef.value = false;
              // 状態変更を無効化して再ビルドを防ぐ
            },
            onWebResourceError: (WebResourceError error) {
              if (!context.mounted) return;
              logger.e('WebView error: ${error.description}', error: error);
              isLoadingRef.value = false;
              // 状態変更を無効化して再ビルドを防ぐ
            },
            onNavigationRequest: (NavigationRequest request) {
              logger.d('WebView navigation request: ${request.url}');
              return NavigationDecision.navigate;
            },
            onUrlChange: (UrlChange change) {
              logger.d('WebView URL changed: ${change.url}');
            },
          ),
        )
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'ModelReadyChannel',
          onMessageReceived: (message) {
            if (!context.mounted) return;
            logger.d('ModelReadyChannel: ${message.message}');
            onWebViewCreated(controller);
          },
        )
        ..addJavaScriptChannel(
          'MusicGeneratedChannel',
          onMessageReceived: (message) {
            if (!context.mounted) return;
            logger.d('MusicGeneratedChannel: ${message.message}');

            try {
              // JSONメッセージをパース
              final jsonData = jsonDecode(message.message);
              logger.d('MusicGeneratedChannel JSON data: $jsonData');

              if (jsonData['type'] == 'generated_music' ||
                  jsonData['type'] == 'demo_music') {
                final musicData = jsonData['data'] as String;
                logger.d('MusicData: ${musicData.substring(0, 50)}...');

                // 音楽生成完了処理を実行
                ref
                    .read(musicGenerationStateNotifierProvider.notifier)
                    .musicGenerationCompleted(message.message);

                logger.d('音楽生成完了処理を開始しました');
              } else {
                logger.w('未対応のメッセージタイプ: ${jsonData['type']}');
              }
            } on Exception catch (e) {
              logger
                ..e('MusicGeneratedChannel message parsing error: $e')
                ..d('Raw message: ${message.message}');
              // フォールバック: 直接メッセージを使用
              ref
                  .read(musicGenerationStateNotifierProvider.notifier)
                  .musicGenerationCompleted(message.message);
            }
          },
        )
        ..addJavaScriptChannel(
          'MusicGenerationErrorChannel',
          onMessageReceived: (message) {
            if (!context.mounted) return;
            logger.e('MusicGenerationErrorChannel: ${message.message}');
            ref
                .read(musicGenerationStateNotifierProvider.notifier)
                .musicGenerationFailed(message.message);
          },
        )
        ..addJavaScriptChannel(
          'DebugChannel',
          onMessageReceived: (message) {
            if (!context.mounted) return;
            logger.d('DebugChannel: ${message.message}');
          },
        )
        // 本番のHTMLコンテンツをロード
        ..loadHtmlString(htmlContent);

      return controller;
    }, []);

    return Dialog(
      backgroundColor: theme.appColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeText(
              text: l10n.musicGenerationInProgress,
              color: theme.appColors.black,
              style: theme.textTheme.h30.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            hSpace(height: 16),
            SizedBox(
              width: 300,
              height: 200,
              child: Stack(
                children: [
                  WebViewWidget(controller: initializedController),
                  // ローディングインジケーターを静的に表示（状態変更なし）
                  Center(
                    child: CircularProgressIndicator(
                      color: theme.appColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            hSpace(height: 16),
            ThemeText(
              text: l10n.aiGeneratingMusicForDog,
              color: theme.appColors.grey,
              style: theme.textTheme.h30.copyWith(fontSize: 14),
              align: TextAlign.center,
            ),
            hSpace(height: 16),
            DialogSecondaryButton(
              text: l10n.close,
              screen: 'music_generation_webview_dialog',
              width: double.infinity,
              callback: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// MusicGenerationWebViewDialogウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(
  name: 'MusicGenerationWebViewDialog',
  type: MusicGenerationWebViewDialog,
)
Widget musicGenerationWebViewDialogUseCase(BuildContext context) {
  final webViewController = useMemoized(WebViewController.new);
  return MusicGenerationWebViewDialog(
    controller: webViewController,
    htmlContent:
        '<html><body><h1>Widgetbook Test</h1></body></html>', // Dummy content for Widgetbook
    onWebViewCreated: (controller) {
      // For Widgetbook, we don't need to do anything specific here.
      // In a real app, this would trigger the music generation.
    },
  );
}
