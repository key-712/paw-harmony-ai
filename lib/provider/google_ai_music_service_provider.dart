import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../utility/const/env.dart';
import '../utility/google_ai_music_service.dart';

/// Google AI音楽生成サービスのプロバイダー
final googleAiMusicServiceProvider = Provider<GoogleAiMusicService>((ref) {
  return GoogleAiMusicService(apiKey: Env.googleAiApiKey);
});
