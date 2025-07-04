import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../import/provider.dart';

/// ネットワークの接続状態の変更の通知を管理するプロバイダ
final networkConnectStateNotifierProvider = StateNotifierProvider<
  NetworkConnectStateNotifier,
  List<ConnectivityResult>
>((ref) {
  return NetworkConnectStateNotifier(ref);
});

/// ネットワークの接続状態の変更を通知するクラス
class NetworkConnectStateNotifier
    extends StateNotifier<List<ConnectivityResult>> {
  /// ネットワークの接続状態の変更を通知するクラス
  NetworkConnectStateNotifier(this._ref) : super([]) {
    _update();
    _streamSubscription = Connectivity().onConnectivityChanged.listen((result) {
      state = result;
    });
  }

  final Ref _ref;

  /// ダイアログの表示非表示の変更を通知するクラス
  late final DialogStateNotifier dialogStateNotifier = _ref.watch(
    dialogStateNotifierProvider.notifier,
  );

  StreamSubscription<List<ConnectivityResult>>? _streamSubscription;

  /// 現在のネットワークの接続状態を取得して、通知します
  Future<void> _update() async {
    state = await Connectivity().checkConnectivity();
  }

  /// ネットワークエラーダイアログを表示します
  Future<bool> showNetworkError({
    required BuildContext context,
    required String screen,
  }) async {
    final localizations = AppLocalizations.of(context)!;

    if (state.isEmpty) return false;
    if (state.last == ConnectivityResult.none && context.mounted) {
      await dialogStateNotifier.showActionDialog(
        screen: screen,
        title: localizations.networkError,
        content: localizations.networkErrorContent,
        buttonLabel: localizations.checkConnection,
        barrierDismissible: false,
        callback: () async {
          await showNetworkError(context: context, screen: screen);
        },
        context: context,
      );
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    super.dispose();
  }
}
