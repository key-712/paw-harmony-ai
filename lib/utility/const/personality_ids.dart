/// 性格IDから多言語キーを取得するMap
const personalityIdToKey = <String, String>{
  '1': 'personalityEasygoing',
  '2': 'personalityActive',
  '3': 'personalityTimid',
  '4': 'personalitySociable',
  '5': 'personalityAffectionate',
  '6': 'personalityMyPace',
};

/// 利用可能な性格IDのリスト
List<String> defaultPersonalityIds() => personalityIdToKey.keys.toList();
