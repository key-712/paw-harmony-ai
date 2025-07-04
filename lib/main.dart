import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'import/provider.dart';
import 'import/utility.dart';

/// アプリケーションのエントリポイント(アプリ起動時の処理)
Future<void> main() async {
  // スプラッシュ画面の表示
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 各種サービスの初期化
  final prefs = await SharedPreferences.getInstance();

  // Firebaseの初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// Firestoreの初期化
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // その他のサービスの初期化
  await Future.wait([
    MobileAds.instance.initialize(),
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    Purchases.setLogLevel(LogLevel.info),
  ]);

  // アプリの起動
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    observers: [ProviderLogger()],
  );

  // スプラッシュ画面を非表示
  FlutterNativeSplash.remove();

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
