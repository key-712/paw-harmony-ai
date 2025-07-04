import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../import/type.dart';

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
    final offerings = await Purchases.getOfferings();
    final package = offerings.current?.monthly;
    if (package == null) {
      state = PurchaseState(isSubscribed: false);
      return;
    }
    await Purchases.purchasePackage(package);
    await _checkSubscriptionStatus();
  }

  /// サブスクリプションのステータスを確認します
  Future<void> _checkSubscriptionStatus() async {
    final purchaseInfo = await Purchases.getCustomerInfo();
    // const entitlementId = APIKey.entitlementId;
    final entitlement = purchaseInfo.entitlements.all['entitlementId'];
    if (entitlement != null && entitlement.isActive) {
      state = PurchaseState(isSubscribed: true);
    } else {
      state = PurchaseState(isSubscribed: false);
    }
  }
}
