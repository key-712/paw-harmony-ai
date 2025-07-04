import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_error.dart';

part 'result.freezed.dart';

/// 実行結果を格納するクラス
@freezed
class Result<T> with _$Result<T> {
  const Result._();

  /// 実行結果(成功)のインスタンス作成します
  const factory Result.success({required T data}) = Success<T>;

  /// 実行結果(失敗)のインスタンス作成します
  const factory Result.failure({required AppError error}) = Failure<T>;

  /// 引数で渡した同期型関数の実行し、実行結果を取得します
  static Result<T> guard<T>({
    required T Function() body,
    required BuildContext context,
  }) {
    try {
      return Result.success(data: body());
    } on Exception catch (e) {
      return Result.failure(error: AppError(error: e, context: context));
    }
  }

  /// 引数で渡した非同期型関数の実行し、実行結果を取得します
  static Future<Result<T>> guardFuture<T>({
    required Future<T> Function() future,
    required BuildContext context,
  }) async {
    try {
      return Result.success(data: await future());
    } on Exception catch (e) {
      return Result.failure(error: AppError(error: e, context: context));
    }
  }

  /// 実行結果(成功)の場合、true。それ以外は、false。
  bool get isSuccess => when(success: (data) => true, failure: (e) => false);

  /// 実行結果(失敗)の場合、true。それ以外は、false。
  bool get isFailure => !isSuccess;

  /// 実行結果が成功の場合に、引数で渡した処理を実行します
  void ifSuccess({required void Function(T data) body}) {
    maybeWhen(
      success: (data) => body(data),
      orElse: () {
        // no-op
      },
    );
  }

  /// 実行結果が失敗の場合に、引数で渡した処理を実行します
  void ifFailure({required void Function(AppError e) body}) {
    maybeWhen(
      failure: (e) => body(e),
      orElse: () {
        // no-op
      },
    );
  }
}

/// クラスTの拡張関数定義
extension ResultObjectExt<T> on T {
  /// 実行結果を成功したものとして、取得します
  Result<T> get asSuccess => Result.success(data: this);

  /// 実行結果を失敗したものとして、取得します
  Result<T> asFailure(Exception e, BuildContext context) =>
      Result.failure(error: AppError(error: e, context: context));
}
