# Domain Error Codes

目的: Main/Renderer 間で扱うドメインエラーのコードを1箇所で参照できるようにする

## maintenance

- code: `INVALID_MAINTENANCE_CONFIG`
- source: `src/shared/domain/maintenanceErrors.ts`
- formatter: `formatMaintenanceConfigValidationError(detail)`
- parser: `parseMaintenanceConfigValidationError(err)`
- 用途:
  - maintenance 設定保存時の入力検証エラー
  - 例: 必須値欠落、範囲外値

## aiModel

- code: `INVALID_AI_MODEL_CONFIG`
- source: `src/shared/domain/aiModelErrors.ts`
- formatter: `formatAiModelConfigValidationError(detail)`
- parser: `parseAiModelDomainError(err)`
- 用途:
  - AI モデル設定保存時の入力検証エラー

- code: `INVALID_AI_MODEL_PRESET`
- source: `src/shared/domain/aiModelErrors.ts`
- formatter: `formatAiModelPresetValidationError(detail)`
- parser: `parseAiModelDomainError(err)`
- 用途:
  - AI プリセット適用時の入力検証エラー

## 運用ルール

- 新しいドメインエラーを追加したら、必ずこのファイルへ追記する。
- Renderer 側では生メッセージではなく `code + detail` を優先して分岐する。
