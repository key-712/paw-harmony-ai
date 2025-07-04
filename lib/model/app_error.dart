import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// アプリで発生するエラーの種類
enum AppErrorType {
  /// ネットワークエラー
  network('ネットワークエラー'),

  /// クライアントエラー
  badRequest('クライアントエラー'),

  /// 認証に失敗しました
  unauthorized('認証に失敗しました'),

  /// リクエストをキャンセルしました
  cancel('リクエストをキャンセルしました'),

  /// タイムアウトエラー
  timeout('タイムアウトエラー'),

  /// サーバーエラー
  server('サーバーエラー'),

  /// バージョンエラー
  version('アップデートのお知らせ'),

  /// 不明なエラー
  unknown('エラー');

  const AppErrorType(this.title);

  /// タイトル
  final String title;
}

/// アプリのエラー内容を格納するクラス
class AppError implements Exception {
  /// アプリのエラー内容を格納するインスタンス作成します
  AppError({Exception? error, required BuildContext context}) {
    final localizations = AppLocalizations.of(context)!;

    message = localizations.errorContent;
    if (error is DioException) {
      logger.e('''
AppError(DioError) ${error.requestOptions.uri} 
${error.error}''');
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          type = AppErrorType.timeout;
          message = localizations.connectionTimeout;

        case DioExceptionType.receiveTimeout:
          type = AppErrorType.timeout;
          message = localizations.receiveTimeout;

        case DioExceptionType.sendTimeout:
          type = AppErrorType.timeout;
          message = localizations.sendTimeout;

        case DioExceptionType.badCertificate:
          type = AppErrorType.server;
          message = localizations.badCertificate;

        case DioExceptionType.connectionError:
          type = AppErrorType.server;
          message = localizations.serverError;

        case DioExceptionType.badResponse:
          switch (error.response?.statusCode) {
            case HttpStatus.badRequest: // 400
              type = AppErrorType.badRequest;
              message = localizations.badRequest;

            case HttpStatus.unauthorized: // 401
              type = AppErrorType.unauthorized;
              message = localizations.sessionTimeout;

            case HttpStatus.internalServerError: // 500
              type = AppErrorType.server;
              message = localizations.internalServerError;

            case HttpStatus.badGateway: // 502
              type = AppErrorType.server;
              message = localizations.badGateway;

            case HttpStatus.serviceUnavailable: // 503
              type = AppErrorType.server;
              message = localizations.serviceUnavailable;

            case HttpStatus.gatewayTimeout: // 504
              type = AppErrorType.server;
              message = localizations.gatewayTimeout;

            case HttpStatus.upgradeRequired: // 426
              type = AppErrorType.version;
              message = localizations.upgradeRequired;

            case HttpStatus.tooManyRequests: // 429
              type = AppErrorType.badRequest;
              message = localizations.tooManyRequests;

            default:
              type = AppErrorType.unknown;
          }

        case DioExceptionType.cancel:
          type = AppErrorType.cancel;
          message = localizations.actionCanceled;

        case DioExceptionType.unknown:
          type = AppErrorType.unknown;
      }
    } else {
      logger.e('AppError(UnKnown): $error');
      type = AppErrorType.unknown;
    }
  }

  /// メッセージ
  late String message;

  /// エラータイプ
  late AppErrorType type;
}
