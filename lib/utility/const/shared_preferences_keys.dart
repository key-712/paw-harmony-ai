/// SharedPreferencesで利用するKeyの値を管理するクラス
class SharedPreferencesKeys {
  /// 初期起動かどうか
  static const initialLaunchKey = 'is_initial_launch';

  /// 初期ホーム画面かどうか
  static const initialHomeKey = 'is_initial_home';

  /// レーティングダイアログの表示日付
  static const ratingDialogDate = 'rating_dialog_date';

  /// レーティングダイアログの表示回数
  static const ratingDialogShown = 'rating_dialog_shown';

  /// 音楽生成回数
  static const generationCountKey = 'generation_count';

  /// 最終生成日
  static const lastGenerationDateKey = 'last_generation_date';
 
  /// Eメール
  static const email = 'email';
}
