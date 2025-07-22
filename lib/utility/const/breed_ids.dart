/// 犬種IDから多言語キーを取得する関数
String getBreedKey(String breedId) {
  switch (breedId) {
    case '1':
      return 'breedToyPoodle';
    case '2':
      return 'breedChihuahua';
    case '3':
      return 'breedShiba';
    case '4':
      return 'breedMiniatureDachshund';
    case '5':
      return 'breedPomeranian';
    case '6':
      return 'breedFrenchBulldog';
    case '7':
      return 'breedGoldenRetriever';
    case '8':
      return 'breedLabradorRetriever';
    case '9':
      return 'breedMix';
    case '10':
      return 'breedWhippet';
    case '11':
      return 'breedAkita';
    case '12':
      return 'breedMaltese';
    case '13':
      return 'breedSiberianHusky';
    case '14':
      return 'breedAlaskanMalamute';
    case '15':
      return 'breedBorderCollie';
    case '16':
      return 'breedAustralianShepherd';
    case '17':
      return 'breedBulldog';
    case '18':
      return 'breedPug';
    case '19':
      return 'breedGermanShepherd';
    case '20':
      return 'breedDoberman';
    case '21':
      return 'breedBeagle';
    case '22':
      return 'breedDachshund';
    case '23':
      return 'breedSamoyed';
    case '24':
      return 'breedGreatPyrenees';
    case '25':
      return 'breedCorgi';
    case '26':
      return 'breedWelshCorgi';
    case '27':
      return 'breedShihTzu';
    case '28':
      return 'breedPekingese';
    case '29':
      return 'breedBerneseMountainDog';
    case '30':
      return 'breedSaintBernard';
    case '31':
      return 'breedBostonTerrier';
    case '32':
      return 'breedWestHighlandWhiteTerrier';
    case '33':
      return 'breedYorkshireTerrier';
    case '34':
      return 'breedNewfoundland';
    case '35':
      return 'breedRetriever';
    case '36':
      return 'breedShetlandSheepdog';
    case '37':
      return 'breedCollie';
    case '38':
      return 'breedBassetHound';
    case '39':
      return 'breedBloodhound';
    case '40':
      return 'breedGreyhound';
    case '41':
      return 'breedOther';
    default:
      return 'breedOther';
  }
}

/// 利用可能な犬種IDのリストを取得
List<String> getAvailableBreedIds() {
  return [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
  ];
}
