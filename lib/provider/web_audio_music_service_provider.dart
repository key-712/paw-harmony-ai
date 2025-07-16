import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../utility/web_audio_music_service.dart';

/// Web Audio API音楽生成サービスのプロバイダー
final webAudioMusicServiceProvider = Provider<WebAudioMusicService>((ref) {
  return WebAudioMusicService();
});
