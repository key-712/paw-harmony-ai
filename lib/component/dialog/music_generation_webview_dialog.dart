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
    final isLoading = useState(true);
    final hasError = useState(false);
    final errorMessage = useState<String?>(null);

    // WebViewの初期化を一度だけ実行（useMemoizedを使用）
    final initializedController = useMemoized(() {
      if (isInitialized.value) return controller;

      logger.d('Initializing WebView...');

      // 初期化フラグを先に設定
      isInitialized.value = true;

      // HTMLコンテンツのデバッグ情報を出力
      logger.d('HTMLコンテンツの長さ: ${htmlContent.length}文字');

      // WebViewの初期化を実行
      controller
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (!context.mounted) return;
              logger.d('WebView onPageStarted: $url');
              isLoading.value = true;
              hasError.value = false;
              errorMessage.value = null;
            },
            onPageFinished: (String url) {
              if (!context.mounted) return;
              logger.d('WebView onPageFinished: $url');
              isLoading.value = false;

              // ページ読み込み完了後にJavaScriptチャンネルの状態を確認
              Future.delayed(const Duration(milliseconds: 1000), () {
                controller.runJavaScript('''
                  console.log('Checking JavaScript channels...');
                  if (window.JavaScriptReadyChannel) {
                    console.log('JavaScriptReadyChannel is available');
                    window.JavaScriptReadyChannel.postMessage('ready');
                  } else {
                    console.log('JavaScriptReadyChannel is not available');
                  }
                  if (window.TestChannel) {
                    console.log('TestChannel is available');
                    window.TestChannel.postMessage('test_from_flutter');
                  } else {
                    console.log('TestChannel is not available');
                  }
                ''');
              });
            },
            onWebResourceError: (WebResourceError error) {
              if (!context.mounted) return;
              logger.e(
                'WebView error: ${error.description}',
                error: error,
                stackTrace: StackTrace.current,
              );
              isLoading.value = false;
              hasError.value = true;
              errorMessage.value = 'WebViewの読み込みに失敗しました: ${error.description}';
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
            if (message.message == 'modelReady') {
              onWebViewCreated(controller);
            }
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
            hasError.value = true;
            errorMessage.value = message.message;
            ref
                .read(musicGenerationStateNotifierProvider.notifier)
                .musicGenerationFailed(message.message);
          },
        )
        ..addJavaScriptChannel(
          'DebugChannel',
          onMessageReceived: (message) {
            if (!context.mounted) return;
            logger.d('🐛 DebugChannel received: ${message.message}');
            // デバッグメッセージの詳細をログに出力
            if (message.message.contains('ERROR')) {
              logger.e('🚨 HTML Error: ${message.message}');
            } else if (message.message.contains('Music generation')) {
              logger.i('🎵 Music Generation: ${message.message}');
            } else if (message.message.contains('Tone.js')) {
              logger.i('🎼 Tone.js: ${message.message}');
            } else {
              logger.d('📝 Debug: ${message.message}');
            }
          },
        )
        ..addJavaScriptChannel(
          'JavaScriptReadyChannel',
          onMessageReceived: (message) {
            logger.d('JavaScriptReadyChannel received: ${message.message}');
            if (message.message == 'ready') {
              logger.d('JavaScriptReadyChannel: ready');
              // JavaScriptの準備ができたので初期化を開始
              Future.microtask(() async {
                try {
                  logger.d('JavaScriptの初期化を開始しました。');
                  await controller.runJavaScript('''
                    console.log("Checking for startInitialization function...");
                    if (typeof startInitialization === "function") {
                      console.log("Calling startInitialization");
                      startInitialization();
                    } else if (typeof initializeAIModel === "function") {
                      console.log("Calling initializeAIModel directly");
                      initializeAIModel();
                    } else {
                      console.error("Neither function found");
                      // フォールバック: 少し待ってから再試行
                      setTimeout(() => {
                        if (typeof startInitialization === "function") {
                          startInitialization();
                        } else if (typeof initializeAIModel === "function") {
                          initializeAIModel();
                        }
                      }, 1000);
                    }
                  ''');

                  // JavaScript初期化後にFlutterReadyChannelの送信を確認
                  Future.delayed(const Duration(milliseconds: 500), () {
                    controller.runJavaScript('''
                      console.log("Checking FlutterReadyChannel availability...");
                      if (window.FlutterReadyChannel) {
                        console.log("FlutterReadyChannel is available, sending message...");
                        window.FlutterReadyChannel.postMessage("flutter_ready");
                      } else {
                        console.error("FlutterReadyChannel is not available");
                      }
                    ''');
                  });
                } on Exception catch (e) {
                  logger.e('JavaScriptの初期化呼び出しに失敗', error: e);
                  // エラーが発生しても、FlutterReadyChannelを送信して続行を試みる
                  if (context.mounted) {
                    logger.d('エラーが発生しましたが、音楽生成を続行します');
                    onWebViewCreated(controller);
                  }
                }
              });
            }
          },
        )
        ..addJavaScriptChannel(
          'TestChannel',
          onMessageReceived: (message) {
            logger.d('TestChannel received: ${message.message}');
          },
        )
        ..addJavaScriptChannel(
          'FlutterReadyChannel',
          onMessageReceived: (message) {
            logger.d('FlutterReadyChannel received: ${message.message}');
            if (message.message == 'flutter_ready') {
              logger.d('FlutterReadyChannel: flutter_ready - 音楽生成を開始します');
              // Flutter側の準備が完了したことを通知
              onWebViewCreated(controller);
            } else {
              logger.d('FlutterReadyChannel: 不明なメッセージ - ${message.message}');
            }
          },
        );

      // タイムアウト処理を削除（FlutterReadyChannelの受信のみで音楽生成を開始）
      // 重複実行を防ぐため、タイムアウト処理は削除

      // HTMLコンテンツをロード
      Future.microtask(() async {
        try {
          final dataUrl = Uri.dataFromString(
            htmlContent,
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'),
          );
          await controller.loadRequest(dataUrl);
          logger.d('HTMLコンテンツのロードを開始しました');

          // 少し待ってからJavaScriptチャンネルの状態を確認
          Future.delayed(const Duration(milliseconds: 500), () {
            controller.runJavaScript(
              'window.JavaScriptReadyChannel ? "ready" : "not_ready"',
            );

            // DebugChannelの状態も確認
            controller.runJavaScript('''
              if (window.DebugChannel) {
                console.log("DebugChannel is available");
                window.DebugChannel.postMessage("Flutter: DebugChannel test message");
              } else {
                console.error("DebugChannel is not available");
              }
            ''');
          });

          // HTML側からのデバッグメッセージが受信されない場合のフォールバック
          Future.delayed(const Duration(milliseconds: 2000), () {
            logger.d('🐛 HTML側からのデバッグメッセージ確認中...');
            controller.runJavaScript('''
              if (window.DebugChannel) {
                console.log("Sending additional debug messages...");
                window.DebugChannel.postMessage("HTML: Additional debug message 1");
                setTimeout(() => {
                  window.DebugChannel.postMessage("HTML: Additional debug message 2");
                }, 100);
                setTimeout(() => {
                  window.DebugChannel.postMessage("HTML: Additional debug message 3");
                }, 200);
              }
            ''');
          });
        } on Exception catch (e) {
          logger.e('HTMLコンテンツのロードに失敗: $e');
        }
      });

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
                  // ローディングインジケーターを条件付きで表示
                  if (isLoading.value)
                    ColoredBox(
                      color: theme.appColors.white.withValues(alpha: 0.8),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: theme.appColors.primary,
                            ),
                            hSpace(height: 8),
                            ThemeText(
                              text: 'HTMLを読み込み中...',
                              color: theme.appColors.grey,
                              style: theme.textTheme.h30.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // エラー表示
                  if (hasError.value && errorMessage.value != null)
                    ColoredBox(
                      color: theme.appColors.white.withValues(alpha: 0.9),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.appColors.error,
                                size: 32,
                              ),
                              hSpace(height: 8),
                              ThemeText(
                                text: 'エラーが発生しました',
                                color: theme.appColors.error,
                                style: theme.textTheme.h30.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              hSpace(height: 4),
                              ThemeText(
                                text: errorMessage.value!,
                                color: theme.appColors.grey,
                                style: theme.textTheme.h30.copyWith(
                                  fontSize: 12,
                                ),
                                align: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
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
