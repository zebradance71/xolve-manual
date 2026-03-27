# Refactor Phase7 Checklist

目的: 壊れやすい分岐の回帰を素早く検出する

## 追加済みスモーク

- [x] `smoke:json-store`
  - 壊れ JSON fallback
  - `.bak` 退避
  - roundtrip read/write
- [x] `test:unit`（maintenance domain）
  - maintenance の validate / sanitize
  - エラーコード format / parse
- [x] `test:unit`（aiModel domain）
  - aiModel の validate / sanitize
  - preset 判定
  - エラーコード format / parse

## 実行コマンド

- [x] `npm run smoke:phase7`
- [x] `npm run build`

## 運用ルール

- [x] 設定系ドメイン変更時は `smoke:phase7` を必ず実行（`release_preflight_checklist.md` にも記載）
- [x] リファクタ差分マージ前に `build` を必ず通す（DoD / preflight の一部として固定）
