import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../utility/magenta_music_service.dart';

/// Magenta.js音楽生成サービスのプロバイダー
final magentaMusicServiceProvider = Provider<MagentaMusicService>((ref) {
  return MagentaMusicService();
});
