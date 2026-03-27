# Quality Gate Routine

目的: 日常開発とリリース前で、同じ品質ゲートを迷わず実行できるようにする。

## 基本コマンド

- 単体テスト: `npm run test:unit`
- リファクタ安全網 + build: `npm run preflight:release`
- 最小 E2E（Electron 起動確認）: `npm run test:e2e:smoke`
- 拡張 E2E（主要画面遷移 + 設定導線確認）: `npm run test:e2e:flow`
- まとめ実行（推奨）: `npm run quality:gate`

## 推奨フロー（開発中）

1. 機能実装・修正
2. `npm run test:unit`
3. 画面/IPC/Main 変更がある場合は `npm run quality:gate`

## 推奨フロー（リリース前）

1. `npm run quality:gate`
2. 必要に応じて `npm run test:e2e:flow:ui`（ライセンス解除済み環境で画面遷移・設定導線確認）
3. `npm run dist:release`

## 補足

- `test:e2e:smoke` はライセンスロック環境でも初期表示確認として成功する。
- `test:e2e:smoke:ui` は `E2E_REQUIRE_SIDEBAR=1` のため、ライセンス解除済み環境でのみ成功する。
- `test:e2e:flow` はロック環境では起動確認のみ、解除環境では `ダッシュボード / 自動運用 / 投稿ログ / 設定` の遷移と設定画面の運用導線ボタン存在を確認する。
- CI では現状 `preflight:release` を実行しており、E2E はローカル運用を基本とする。

## 最新実行履歴

- 2026-03-26
  - `npm run test:e2e:flow:ui`: pass（ライセンス解除済み環境）
  - `npm run quality:gate`: pass（`test:unit` / `build` / `test:e2e:smoke`）
