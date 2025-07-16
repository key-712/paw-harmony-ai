# Google AI Lyria RealTime 音楽生成機能

## 概要

このアプリケーションでは、Google AIのLyria RealTimeを使用して犬のためのカスタマイズされた音楽を生成します。Lyria RealTimeは、リアルタイムで音楽を生成できる最先端のAI技術です。

## 機能

### 音楽生成の特徴
- **リアルタイム生成**: Lyria RealTimeを使用して即座に音楽を生成
- **犬に最適化**: 犬の年齢、犬種、性格に基づいてカスタマイズ
- **シーン別対応**: 留守番中、就寝前、ストレス時など、状況に応じた音楽
- **高品質音声**: 48kHz、ステレオ出力で高品質な音楽を生成

### 生成設定
- **長さ**: 30秒
- **サンプリングレート**: 48kHz
- **チャンネル数**: 2（ステレオ）
- **BPM**: 120（デフォルト）
- **キー**: Cメジャー（デフォルト）
- **スケール**: C_MAJOR_A_MINOR（デフォルト）

## セットアップ

### 1. Google AI APIキーの取得
1. [Google AI Studio](https://ai.google.dev/)にアクセス
2. APIキーを取得
3. プロジェクトの環境変数に設定

### 2. 環境変数の設定
```bash
# dart_env/dev.env
googleAiApiKey=your_google_ai_api_key_here

# dart_env/prod.env
googleAiApiKey=your_google_ai_api_key_here
```

### 3. アプリのビルド
```bash
# 開発環境
flutter run --dart-define-from-file=dart_env/dev.env

# 本番環境
flutter run --dart-define-from-file=dart_env/prod.env
```

## 使用方法

### 1. シーンの選択
以下のシーンから選択：
- 留守番中
- 就寝前
- ストレスフル
- 長距離移動中
- 日常の癒し
- 療養/高齢犬ケア

### 2. 犬の状態の選択
以下の状態から選択：
- 落ち着かせたい
- リラックスさせたい
- 興奮を抑えたい
- 安心させたい
- 安眠させたい

### 3. 追加情報の入力（オプション）
犬の個性や特別な要望があれば入力

### 4. 音楽生成
「音楽を生成」ボタンを押すと、Google AI Lyria RealTimeが音楽を生成します。

## 技術仕様

### API エンドポイント
```
https://generativelanguage.googleapis.com/v1beta/models/lyria-realtime-2:generateContent
```

### リクエスト形式
```json
{
  "contents": [
    {
      "parts": [
        {
          "text": "プロンプト"
        }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 1.1,
    "topK": 40,
    "topP": 0.8,
    "maxOutputTokens": 8192
  },
  "tools": [
    {
      "functionDeclarations": [
        {
          "name": "generate_music",
          "description": "Generate music based on the provided prompt and configuration",
          "parameters": {
            "type": "object",
            "properties": {
              "duration": {
                "type": "integer",
                "description": "Duration of the music in seconds",
                "minimum": 1,
                "maximum": 300
              },
              "sample_rate": {
                "type": "integer",
                "description": "Sample rate in Hz",
                "enum": [22050, 44100, 48000]
              },
              "num_channels": {
                "type": "integer",
                "description": "Number of audio channels",
                "enum": [1, 2]
              },
              "density": {
                "type": "number",
                "description": "Density of musical elements (0.0 to 1.0)",
                "minimum": 0.0,
                "maximum": 1.0
              },
              "brightness": {
                "type": "number",
                "description": "Brightness of the music (0.0 to 1.0)",
                "minimum": 0.0,
                "maximum": 1.0
              },
              "bpm": {
                "type": "integer",
                "description": "Beats per minute",
                "minimum": 60,
                "maximum": 200
              },
              "scale": {
                "type": "string",
                "description": "Musical scale",
                "enum": [
                  "C_MAJOR_A_MINOR",
                  "G_MAJOR_E_MINOR",
                  "D_MAJOR_B_MINOR",
                  "A_MAJOR_F_SHARP_MINOR",
                  "E_MAJOR_C_SHARP_MINOR",
                  "B_MAJOR_G_SHARP_MINOR",
                  "F_SHARP_MAJOR_D_SHARP_MINOR",
                  "C_SHARP_MAJOR_A_SHARP_MINOR"
                ]
              },
              "key": {
                "type": "string",
                "description": "Musical key",
                "enum": ["C", "G", "D", "A", "E", "B", "F#", "C#"]
              },
              "mode": {
                "type": "string",
                "description": "Musical mode",
                "enum": ["major", "minor"]
              },
              "reverb": {
                "type": "number",
                "description": "Reverb amount (0.0 to 1.0)",
                "minimum": 0.0,
                "maximum": 1.0
              },
              "delay": {
                "type": "number",
                "description": "Delay amount (0.0 to 1.0)",
                "minimum": 0.0,
                "maximum": 1.0
              },
              "mute_bass": {
                "type": "boolean",
                "description": "Whether to mute bass"
              },
              "mute_drums": {
                "type": "boolean",
                "description": "Whether to mute drums"
              },
              "only_bass_and_drums": {
                "type": "boolean",
                "description": "Whether to only include bass and drums"
              },
              "seed": {
                "type": "integer",
                "description": "Random seed for generation"
              }
            },
            "required": [
              "duration",
              "sample_rate",
              "num_channels",
              "density",
              "brightness",
              "bpm",
              "scale",
              "key",
              "mode",
              "reverb",
              "delay",
              "mute_bass",
              "mute_drums",
              "only_bass_and_drums",
              "seed"
            ]
          }
        }
      ]
    }
  ],
  "toolConfig": {
    "functionCallingConfig": {
      "mode": "AUTO",
      "allowedFunctionNames": ["generate_music"]
    }
  }
}
```

### レスポンス形式
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "functionResponse": {
              "response": {
                "audio_data": "base64_encoded_audio_data",
                "generation_config": {
                  "duration": 30,
                  "sample_rate": 48000,
                  "num_channels": 2,
                  "density": 0.5,
                  "brightness": 0.5,
                  "bpm": 120,
                  "scale": "C_MAJOR_A_MINOR",
                  "key": "C",
                  "mode": "major",
                  "reverb": 0.3,
                  "delay": 0.1,
                  "mute_bass": false,
                  "mute_drums": false,
                  "only_bass_and_drums": false,
                  "seed": 123456
                }
              }
            }
          }
        ]
      }
    }
  ]
}
```

## プロンプト生成ロジック

### シーン別音楽スタイル
- **留守番中**: 静かなアンビエント音楽、自然音、ソフトなピアノメロディ
- **就寝前**: 平和な子守唄、ソフトな弦楽器とリズム
- **ストレスフル**: 瞑想音楽、癒しの周波数と波
- **長距離移動中**: リラックスした旅行音楽、スムーズなジャズ要素
- **日常の癒し**: 癒し音楽、温かい音色とハーモニー
- **療養/高齢犬ケア**: 治療音楽、ソフトなクラシック要素

### 犬種別調整
- **小型犬（チワワ、トイプードル）**: 高音域の癒し音
- **大型犬（ゴールデン、ラブラドール）**: 温かく深い音色
- **日本犬（柴犬、秋田）**: 伝統的で平和な要素
- **その他**: 全犬種に適した普遍的な癒し特性

## エラーハンドリング

### 一般的なエラー
- **APIキー無効**: Google AI APIキーが正しく設定されていない
- **ネットワークエラー**: インターネット接続の問題
- **タイムアウト**: 音楽生成に時間がかかりすぎた場合
- **クォータ超過**: API使用量制限に達した場合

### 対処法
1. APIキーの確認
2. ネットワーク接続の確認
3. しばらく待ってから再試行
4. サポートチームへの連絡

## パフォーマンス

### 生成時間
- 通常: 30-60秒
- 最大: 180秒（タイムアウト）

### 音声品質
- サンプリングレート: 48kHz
- ビット深度: 16bit
- チャンネル: ステレオ
- 形式: WAV

## セキュリティ

### APIキーの管理
- 環境変数での管理
- 本番環境での暗号化
- 定期的なキーのローテーション

### データ保護
- 生成された音楽の安全な保存
- ユーザーデータの暗号化
- プライバシーポリシーの遵守

## 今後の改善予定

### 機能拡張
- より長い音楽の生成（最大5分）
- リアルタイム音楽生成
- 音楽の継続再生
- カスタム楽器の選択

### 最適化
- 生成速度の向上
- 音声品質の改善
- より細かい音楽制御
- 犬の反応に基づく動的調整

## 参考資料

- [Google AI Lyria RealTime Documentation](https://ai.google.dev/gemini-api/docs/music-generation?hl=ja)
- [Google AI Studio](https://ai.google.dev/)
- [Flutter Documentation](https://docs.flutter.dev/) 