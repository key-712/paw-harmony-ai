import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../import/type.dart';
import '../import/utility.dart';

/// 購入状態の状態管理対象データの変更の通知を管理するプロバイダ
final purchaseStateNotifierProvider =
    StateNotifierProvider<PurchaseStateNotifier, PurchaseState>(
      PurchaseStateNotifier.new,
    );

/// 購入状態の状態管理対象データの変更を通知するクラス
class PurchaseStateNotifier extends StateNotifier<PurchaseState> {
  /// 購入状態の状態管理対象データの変更を通知するクラス
  PurchaseStateNotifier(this._ref) : super(PurchaseState(isSubscribed: false));

  // ignore: unused_field
  final Ref _ref;

  /// サブスクリプションを購入します
  Future<void> purchaseSubscription() async {
    try {
      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.monthly;
      if (package == null) {
        state = PurchaseState(isSubscribed: false);
        return;
      }
      await Purchases.purchasePackage(package);
      await _checkSubscriptionStatus();
    } on PlatformException catch (e) {
      // RevenueCatが初期化されていない場合
      if (e.code == '23' || e.code == 'CONFIGURATION_ERROR') {
        logger.w('RevenueCat is not properly initialized.');
        return;
      }
      rethrow;
    } catch (e) {
      logger.e('Unexpected error during purchase: $e');
      rethrow;
    }
  }

  /// サブスクリプションのステータスを確認します
  Future<void> _checkSubscriptionStatus() async {
    try {
      final purchaseInfo = await Purchases.getCustomerInfo();
      // const entitlementId = 'premium';
      final entitlement = purchaseInfo.entitlements.all['premium'];
      if (entitlement != null && entitlement.isActive) {
        state = PurchaseState(isSubscribed: true);
      } else {
        state = PurchaseState(isSubscribed: false);
      }
    } on PlatformException catch (e) {
      // RevenueCatが初期化されていない場合
      if (e.code == '23' || e.code == 'CONFIGURATION_ERROR') {
        logger.w('RevenueCat is not properly initialized.');
        state = PurchaseState(isSubscribed: false);
        return;
      }
      rethrow;
    } on Exception catch (e) {
      logger.e('Unexpected error checking subscription status: $e');
      state = PurchaseState(isSubscribed: false);
    }
  }
}
