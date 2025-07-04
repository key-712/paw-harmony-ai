import 'package:flutter/cupertino.dart';
import 'package:platform/platform.dart';

@visibleForTesting

/// プラットフォーム情報を管理するクラス
Platform platform = const LocalPlatform();

/// Androidかどうか
bool get isAndroid => platform.isAndroid;

/// iOSかどうか
bool get isIOS => platform.isIOS;
