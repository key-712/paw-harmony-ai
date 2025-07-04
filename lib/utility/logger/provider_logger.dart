import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/utility.dart';

/// プロバイダのステート変化をログに残すクラス
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    logger.d('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "newValue": "$newValue"
}''');
  }
}
