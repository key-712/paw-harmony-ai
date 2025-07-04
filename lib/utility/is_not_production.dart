/// 本番以外の環境かどうかを判定する
bool isNotProduction() {
  return const String.fromEnvironment('flavor') != 'prod';
}
