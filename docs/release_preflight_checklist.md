# Release Preflight Checklist

目的: 出荷前に最低限の品質ゲートを一本化する

## 1. 自動チェック（必須）

- [ ] `npm run preflight:release` を実行
  - `smoke:phase7`（現在は `test:unit` のみを実行）
  - `build`（型・ビルド整合）
- [ ] `npm run test:e2e:smoke` を実行（最低限の Electron 起動/初期表示確認）
- [x] `npm run test:e2e:flow:ui` を実行（UI必須モードの導線確認）
  - 実施日: 2026-03-26
- [x] まとめ実行する場合は `npm run quality:gate` を実行
  - 実施日: 2026-03-26
  - 結果: pass（`test:unit` / `build` / `test:e2e:smoke`）

## 2. ログ確認（フェーズ6）

- [ ] 設定画面を開き、以下の perf ログが出ることを確認
  - `[perf][settings:init] maintenance:getConfig ...ms`
  - `[perf][settings:init] maintenance:getUsage ...ms`
  - `[perf][settings:init] aiModel:getConfig ...ms`
  - `[perf][settings:init] total ...ms`
- [ ] 起動時に以下のメンテログが出ることを確認
  - `[maintenance:startup] enabled` または `[maintenance:startup] disabled`
  - `[perf][maintenance:startup] total ...ms`

## 3. 変更時ルール

- [ ] 設定系（maintenance / aiModel / jsonStore / settingsApi）変更時は preflight を必ず実行
- [ ] preflight 成功前に release 作業へ進まない
