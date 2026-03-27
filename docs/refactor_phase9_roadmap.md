# Refactor Phase9 Roadmap

目的: 現在の分割構成を拡張しやすい運用形に固定する

## 責務マップ（Main）

- `src/main/main.ts`
  - Electron ライフサイクル配線のみ
  - `whenReady` / `activate` / `window-all-closed`
- `src/main/usecases/bootstrapUsecase.ts`
  - 起動準備、初期化、ハンドラ登録、バックグラウンドジョブ開始の統合
- `src/main/usecases/maintenanceUsecase.ts`
  - maintenance IPC
  - 起動時/手動/定期メンテ実行
  - 実行時間ログ
- `src/main/usecases/aiModelUsecase.ts`
  - aiModel IPC
  - preset/config バリデーション入口
- `src/main/usecases/appUtilityUsecase.ts`
  - `shell:openExternal`
  - `workerLog:*`
- `src/main/usecases/windowUsecase.ts`
  - ウィンドウ生成と activate 時再生成

## 責務マップ（Renderer Settings）

- `src/renderer/ui/settings/useSettingsController.ts`
  - Settingsページの統合コントローラ（公開インターフェース）
- `src/renderer/ui/settings/useMaintenanceSettings.ts`
  - 保守設定の初期化/保存/実行/初期化
  - 計測ログ（設定初期化）
- `src/renderer/ui/settings/useAiModelSettings.ts`
  - aiModel保存/プリセット適用
- `src/renderer/ui/settings/useLicenseSettings.ts`
  - ライセンスの保存/再認証/解放
- `src/renderer/ui/settings/*Section.tsx`
  - UIセクション描画に専念（基本/AIモデル/保守）

## ドメイン契約（Shared）

- `src/shared/domain/maintenanceConfig.ts`
  - maintenance型、sanitize、validate
- `src/shared/domain/maintenanceErrors.ts`
  - maintenanceエラーコード format/parse
- `src/shared/domain/aiModelConfig.ts`
  - aiModel型ルール、sanitize、validate、preset
- `src/shared/domain/aiModelErrors.ts`
  - aiModelエラーコード format/parse

## フェーズ9タスク（推奨順）

1. 設定初期化ログの収集基準を固定（何msで改善判定するか） ✅
2. `preflight:release` を CI で回せる形へ整備（任意） ✅
3. smoke スクリプトを Vitest へ段階移行（最初は1本） ✅
4. chunk warning 対策として code splitting 候補を3箇所抽出 ✅
5. ドメインエラーコード一覧を `docs` に集約 ✅

## 計測ログの判定基準（Phase9-1）

### 対象ログ

- `[perf][settings:init] maintenance:getConfig ...ms`
- `[perf][settings:init] maintenance:getUsage ...ms`
- `[perf][settings:init] aiModel:getConfig ...ms`
- `[perf][settings:init] total ...ms`
- `[perf][maintenance:startup] total ...ms`
- `[perf][maintenance:manual] total ...ms`

### 目標値（目安）

- `settings:init total`
  - 目標: 300ms 以下
  - 警戒: 500ms 超
- `maintenance:startup total`
  - 目標: 1000ms 以下
  - 警戒: 2000ms 超
- `maintenance:manual total`
  - 目標: 1500ms 以下
  - 警戒: 3000ms 超

### 判定ルール

- 3回計測して中央値で判定する
- 前回中央値より 20% 以上悪化したら要調査
- 警戒値を超えた場合は release 前に原因メモを残す

## Definition of Done（Phase9）

- [ ] 責務マップが現行実装と一致
- [ ] 次フェーズの着手順が文書化されている
- [ ] リリース前の実行導線（`preflight:release`）が維持される

## code splitting 候補（抽出結果）

1. `src/renderer/ui/App.tsx` の `AccountsPage`
   - 大規模フォーム/UIを同ファイル内で持っており、現状は route-level lazy の対象外。
   - 次段階で `AccountsPage.tsx` へ分離し、`lazy` 適用余地が大きい。
2. `src/renderer/ui/App.tsx` の `OverviewPage`
   - エディタ・プレビュー・モーダル連携で依存が多く、初期ロード寄与が大きい。
   - `OverviewPage.tsx` 分離後に route-level lazy で遅延読込可能。
3. `src/renderer/ui/ScheduleCalendarPanel.tsx` 周辺
   - カレンダー機能は用途限定で、初回表示時に不要なケースが多い。
   - `/schedules` ルート専用チャンクへ寄せる価値がある。
