import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../import/type.dart';
import '../import/utility.dart';

/// FirebaseAnalyticsクラスのインスタンスを管理するプロバイダ
final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>(
  (ref) => FirebaseAnalytics.instance,
);

/// FirebaseAnalyticsServiceクラスのインスタンスを管理するプロバイダ
final firebaseAnalyticsServiceProvider = Provider<FirebaseAnalyticsService>(
  (ref) {
    final service = FirebaseAnalyticsService(
      firebaseAnalytics: ref.watch(firebaseAnalyticsProvider),
    )..setUserId();
    return service;
  },
);

/// FirebaseAnalyticsを操作するサービスクラス
class FirebaseAnalyticsService {
  /// FirebaseAnalyticsを操作するサービスクラス
  FirebaseAnalyticsService({
    required this.firebaseAnalytics,
  });

  /// FirebaseAnalyticsのインスタンス
  final FirebaseAnalytics firebaseAnalytics;

  /// ユーザーIDを設定します
  Future<void> setUserId() async {
    await firebaseAnalytics.setUserId(
      id: const Uuid().v4(),
    );
  }

  /// ボタンをタップしたことを記録します
  Future<void> tapButton({
    required TapButtonLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapButton,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// カードをタップしたことを記録します
  Future<void> tapCard({
    required TapCardLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapCard,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// アイコンボタンをタップしたことを記録します
  Future<void> tapIconButton({
    required TapIconButtonLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapIconButton,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// スイッチをタップしたことを記録します
  Future<void> tapSwitch({
    required TapSwitchLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapSwitch,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// リンクテキストをタップしたことを記録します
  Future<void> tapLinkText({
    required TapLinkTextLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapLinkText,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// リンクテキストをタップしたことを記録します
  Future<void> tapBottomNavigation({
    required TapBottomNavigationLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapBottomNavigation,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// ハンバーガーメニュー(親)をタップしたことを記録します
  Future<void> tapListExpansionMenu({
    required TapHamburgerExpansionMenuLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapListExpansionMenu,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// ハンバーガーメニュー(子)をタップしたことを記録します
  Future<void> tapListMenu({
    required TapHamburgerMenuLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapListMenu,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// プッシュ通知をタップしたことを記録します
  Future<void> tapPushNotification({
    required TapPushNotificationLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapPushNotification,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// ページインジケータドットをタップしたことを記録します
  Future<void> tapPageIndicatorDot({
    required TapPageIndicatorDotLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapPageIndicatorDot,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// クイックアクションをタップしたことを記録します
  Future<void> tapQuickAction({
    required TapQuickActionLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.tapQuickAction,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// テキストフィールドが入力開始したことを記録します
  Future<void> inputStartTextField({
    required InputStartTextFieldLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.inputStartTextField,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// テキストフィールドが入力完了したことを記録します
  Future<void> submitTextField({
    required SubmitTextFieldLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.submitTextField,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// 画面遷移したことを記録します
  Future<void> transitScreen({
    required TransitLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.transitScreen,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// ページインジケータが遷移したことを記録します
  Future<void> transitPageIndicator({
    required TransitLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.transitPageIndicator,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// APIをリクエストしたことを記録します
  Future<void> requestApi({
    required RequestApiLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.requestApi,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// APIのレスポンスを記録します
  Future<void> responseApi({
    required ResponseApiLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.responseApi,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// プッシュ通知設定許可ダイアログの回答したことを記録します
  Future<void> selectDevicePushNotificationSetting({
    required SelectPermissionDialogLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.selectDevicePushNotificationSetting,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }

  /// トラッキング許可ダイアログの回答したことを記録します
  Future<void> selectRequestTrackingAuthorization({
    required SelectPermissionDialogLog parameters,
  }) async {
    await firebaseAnalytics.logEvent(
      name: FirebaseAnalyticsEventNames.selectRequestTrackingAuthorization,
      parameters: formatLogParameters(json: parameters.toJson()),
    );
  }
}
