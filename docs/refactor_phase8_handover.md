# Refactor Phase8 Handover

目的: リファクタ成果を運用可能な形で引き継ぐ

## 実施サマリ（Phase1-7）

- Phase1: 安全ネット固定、設定定数一元化、Settings画面分割
- Phase2: JSONストア共通化（atomic write / fallback / `.bak`）
- Phase3: Mainロジックの usecase 分割（maintenance / aiModel / utility / bootstrap / window）
- Phase4: Renderer設定画面のセクション分割と controller フック分離
- Phase5: ドメインルール明文化（maintenance / aiModel の型・validate・error契約）
- Phase6: パフォーマンス計測ログ追加、設定初期化IPCの並列化
- Phase7: 回帰スモーク拡張（json-store / maintenance / aiModel）

## 日常運用コマンド

- 開発ビルド確認: `npm run build`
- フェーズ7安全ネット: `npm run smoke:phase7`
- リリース前統合チェック: `npm run preflight:release`

## リリース導線

1. `npm run preflight:release`
2. 手動最小確認（設定表示・保存・起動ログ）
3. `npm run dist:release`

## 確認すべき主要ログ

- 設定初期化:
  - `[perf][settings:init] maintenance:getConfig ...ms`
  - `[perf][settings:init] maintenance:getUsage ...ms`
  - `[perf][settings:init] aiModel:getConfig ...ms`
  - `[perf][settings:init] total ...ms`
- 起動時メンテ:
  - `[maintenance:startup] enabled` または `disabled`
  - `[perf][maintenance:startup] total ...ms`

## 既知メモ（次フェーズ候補）

- Vite の chunk size warning は継続中（機能上のエラーではない）
- 必要に応じて code splitting / lazy import を段階適用
- 回帰テストを将来的に test runner（Vitest等）へ移行
