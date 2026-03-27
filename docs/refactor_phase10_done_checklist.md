# Refactor Phase10 Done Checklist

目的: リファクタ全体の完了判定を固定し、クローズ可否を明確化する

## 完了判定（必須）

- [x] `npm run preflight:release` が成功する
- [x] `npm run build` が成功する
- [x] 設定系ドメインの smoke が全て成功する
  - `test:unit`（jsonStore / maintenance / aiModel domain）
- [x] Main/Renderer の責務分離がドキュメント化されている
  - `docs/refactor_phase8_handover.md`
  - `docs/refactor_phase9_roadmap.md`

## 既知リスク（許容）

- [x] Vite chunk size warning が継続（機能影響なし）
- [x] 自動テストは Vitest 中心（残る smoke は段階整理対象）

## クローズ条件

- [x] preflight 成功ログを最終記録済み
- [x] リリース導線が一本化されている
  - `npm run preflight:release`
  - `npm run dist:release`

## 備考

- 設定関連に変更が入る場合は必ず `npm run preflight:release` を再実行する。
