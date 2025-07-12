import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../import/utility.dart';
import '../l10n/app_localizations.dart';

/// アプリで発生するエラーの種類
enum AppErrorType {
  /// ネットワークエラー
  network,

  /// クライアントエラー
  badRequest,

  /// 認証に失敗しました
  unauthorized,

  /// リクエストをキャンセルしました
  cancel,

  /// タイムアウトエラー
  timeout,

  /// サーバーエラー
  server,

  /// バージョンエラー
  version,

  /// 不明なエラー
  unknown;

  /// エラータイプのタイトルを取得
  String getTitle(AppLocalizations l10n) {
    switch (this) {
      case AppErrorType.network:
        return l10n.networkError;
      case AppErrorType.badRequest:
        return l10n.badRequest;
      case AppErrorType.unauthorized:
        return l10n.unauthorized;
      case AppErrorType.cancel:
        return l10n.cancel;
      case AppErrorType.timeout:
        return l10n.timeout;
      case AppErrorType.server:
        return l10n.serverError;
      case AppErrorType.version:
        return l10n.upgradeRequired;
      case AppErrorType.unknown:
        return l10n.error;
    }
  }
}

/// アプリのエラー内容を格納するクラス
class AppError implements Exception {
  /// アプリのエラー内容を格納するインスタンス作成します
  AppError({Exception? error, required BuildContext context}) {
    final l10n = AppLocalizations.of(context)!;

    message = l10n.errorContent;
    if (error is DioException) {
      logger.e('''
AppError(DioError) ${error.requestOptions.uri} 
${error.error}''');
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          type = AppErrorType.timeout;
          message = l10n.connectionTimeout;

        case DioExceptionType.receiveTimeout:
          type = AppErrorType.timeout;
          message = l10n.receiveTimeout;

        case DioExceptionType.sendTimeout:
          type = AppErrorType.timeout;
          message = l10n.sendTimeout;

        case DioExceptionType.badCertificate:
          type = AppErrorType.server;
          message = l10n.badCertificate;

        case DioExceptionType.connectionError:
          type = AppErrorType.server;
          message = l10n.serverError;

        case DioExceptionType.badResponse:
          switch (error.response?.statusCode) {
            case HttpStatus.badRequest: // 400
              type = AppErrorType.badRequest;
              message = l10n.badRequest;

            case HttpStatus.unauthorized: // 401
              type = AppErrorType.unauthorized;
              message = l10n.sessionTimeout;

            case HttpStatus.internalServerError: // 500
              type = AppErrorType.server;
              message = l10n.internalServerError;

            case HttpStatus.badGateway: // 502
              type = AppErrorType.server;
              message = l10n.badGateway;

            case HttpStatus.serviceUnavailable: // 503
              type = AppErrorType.server;
              message = l10n.serviceUnavailable;

            case HttpStatus.gatewayTimeout: // 504
              type = AppErrorType.server;
              message = l10n.gatewayTimeout;

            case HttpStatus.upgradeRequired: // 426
              type = AppErrorType.version;
              message = l10n.upgradeRequired;

            case HttpStatus.tooManyRequests: // 429
              type = AppErrorType.badRequest;
              message = l10n.tooManyRequests;

            default:
              type = AppErrorType.unknown;
          }

        case DioExceptionType.cancel:
          type = AppErrorType.cancel;
          message = l10n.actionCanceled;

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
