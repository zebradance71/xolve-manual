# Refactor Final Summary（Phase0–17）

目的: 今回のリファクタ全体を 1 ファイルで俯瞰できるようにし、今後の保守・機能追加の土台とする。

---

## 1. 全体ゴールと前提

- **ゴール**
  - 挙動を壊さずに、設定まわり・起動フロー・AutoEngagement・ログ画面を中心に「読みやすさ」「変更しやすさ」「安全なリリース導線」「初期表示の体感速度」を改善する。
- **前提**
  - すべてのフェーズで `npm run build` をゲートに通過。
  - 重要どころは `npm run preflight:release` に統合（jsonStore / maintenance / aiModel domain テスト + build）。
  - 既存の UI/IPC の契約は維持（リファクタにより API 仕様は変えない）。

---

## 2. フェーズ別サマリ（ざっくり）

- **Phase0–1: 安全ネット & Settings 基盤**
  - 手動スモークチェックリストの固定。
  - `appDefaults.ts` で設定デフォルト値を一元管理。
  - `SettingsPage` をパネル分割し、`useSettingsController` を導入。

- **Phase2–3: JSONストア共通化 & Main usecase 分離**
  - `jsonStore.ts` に read/write/atomic write/壊れ JSON `.bak` 退避を集約。
  - `maintenanceConfigStore` / `aiModelConfigStore` の重複 I/O を削除。
  - `main.ts` を usecase 群（maintenance / aiModel / appUtility / bootstrap / window）へ分離。

- **Phase4–6: Settings ロジック分解 & ドメインルール & 計測**
  - `useMaintenanceSettings` / `useAiModelSettings` / `useLicenseSettings` に責務分割。
  - `maintenanceConfig.ts` / `aiModelConfig.ts` に型・sanitize・validate・preset を定義。
  - `maintenanceErrors.ts` / `aiModelErrors.ts` でエラーコード format/parse を共通化。
  - Settings 初期化 IPC を `Promise.all` で並列化し、`[perf][settings:init] ...` ログを追加。

- **Phase7–10: スモーク→Vitest / CI & DoD 固定**
  - `smoke-json-store` を Vitest 化（`jsonStore.test.ts`）し、`smoke:phase7` を `test:unit` 統合へ整理。
  - `vitest.config.ts` を導入し、`dist/**` を除外。
  - GitHub Actions で `preflight:release` を自動実行できる形に調整。
  - `refactor_phase10_done_checklist.md` で DoD と既知リスク（chunk warning 等）を固定。

- **Phase11–13: 実運用まわりの整備**
  - release 用 `prepare-release.js` の整備。
  - docs に preflight / dist / Prisma まわりのセットアップ手順を追加。
  - `domain_error_codes.md` で maintenance / aiModel のエラーコード参照先を集約。

- **Phase12–17: Vite チャンク最適化 & エラーメッセージ分離**
  - `SettingsPage` 内パネル (`Api/General/License`) を `React.lazy` + `Suspense` 化。
  - `App.tsx` から以下を分離・lazy import:
    - `AccountsPage`
    - `OverviewPage`
    - `SchedulesPage`
    - 各 route のページコンポーネント (`TemplatesPage` / `AutoEngagementPage` / `PostLogsPage` / `SettingsPage`)
  - `ThreadGeneratorModal` など、実行時にのみ必要なモーダルを遅延読み込みに変更。
  - `MSG_APP_MODE_REQUIRED` を軽量モジュール `appModeMessages.ts` に分離。
  - ログ種別ラベルを `postLogMessages.ts` へ分離し、`userMessages.ts` を「エラーメッセージ変換ロジック」に専念させた。
  - 最終的な Renderer 初期チャンク:
    - メインバンドル `index-*.js` ≒ **267 kB（gzip 約 85 kB）** まで縮小。

---

## 3. 現在の「責務マップ」要約

### Main プロセス

- `main.ts`
  - Electron ライフサイクル配線のみ（`whenReady` / `activate` / `window-all-closed`）。
- `usecases/bootstrapUsecase.ts`
  - Prisma 初期化 / IPC ハンドラ登録 / 起動時メンテ / バックグラウンドジョブ開始。
- `usecases/maintenanceUsecase.ts`
  - 起動時 / 手動 / 定期メンテ（ログ付き）と IPC。
- `usecases/aiModelUsecase.ts`
  - AIモデル設定・プリセットの validate / save / load の IPC 入口。
- `usecases/appUtilityUsecase.ts`
  - `shell:openExternal` や workerLog まわりの IPC。
- `usecases/windowUsecase.ts`
  - BrowserWindow の生成と activate 時の再生成。
- `jsonStore.ts` / `maintenanceConfigStore.ts` / `aiModelConfigStore.ts`
  - JSON 設定ファイルの読み書きと domain validate の境界。

### Renderer（設定・投稿・AutoEngagement）

- Settings 関連:
  - `SettingsPage.tsx`
    - `React.lazy` で各パネルを読み込みつつ、`useSettingsController` を入口として利用。
  - `useSettingsController.ts`
    - Settings 画面全体の state・IPC 呼び出しを統合（domain hook へ委譲）。
  - `useMaintenanceSettings.ts` / `useAiModelSettings.ts` / `useLicenseSettings.ts`
    - それぞれ保守・AIモデル・ライセンスのロード/保存/実行ロジック。

- Overview（投稿エディタ）:
  - `OverviewPage.tsx`
    - Draft 管理 / AIリライト連携 / CSVインポート / スケジュール作成を一括管理。
  - `useCreateScheduleFromEditor.ts`
    - Overview からの予約作成ロジックとエラー文言。

- Accounts / AutoEngagement / Logs:
  - `AccountsPage.tsx`
    - 右ペインで API キー / OAuth / プロキシ / AI リライトプリセットを編集。
  - `AutoEngagementPage.tsx` / `useAutoEngagement.ts`
    - 自動運用設定とシミュレーション。
  - `PostLogsPage.tsx` / `usePostLogs.ts`
    - 直近ログの一覧と、`postLogStatusLabel` / `postLogTypeLabel` による表示。

### Shared（ドメイン・エラー）

- 設定ドメイン:
  - `maintenanceConfig.ts` / `aiModelConfig.ts`
    - 型定義 / sanitize / validate / preset 定義。
- エラー:
  - `maintenanceErrors.ts` / `aiModelErrors.ts`
    - ドメインエラーコードの format/parse。
  - `userMessages.ts`
    - 汎用エラーメッセージ変換（ログ・トースト用）。
  - `appModeMessages.ts`
    - アプリモード必須メッセージの小さな共通モジュール。
  - `postLogMessages.ts`
    - ログ種別表示用ラベル（成功/失敗/種別名）。
  - `domain_error_codes.md`
    - 上記エラーコード一覧の docs 集約。

---

## 4. 運用ルール（リリース・変更時のチェック）

### 開発〜リリースの基本フロー

1. コード変更
2. `npm run test:unit`
3. 設定・ドメイン・起動まわりを触った場合は `npm run preflight:release`
4. 問題なければ `npm run dist:release`
5. 実績: 2026-03-26 に `npm run quality:gate` を実行し、`test:unit` / `build` / `test:e2e:smoke` がすべて pass

### 変更時に特に見るべきポイント

- Settings / 予約 / AutoEngagement を触る変更:
  - ドメイン validate で例外にならないか。
  - Renderer 側で `userFacingMessage` 経由のエラー表示が崩れていないか。
  - `[perf][settings:init total]` が 300ms 近辺に収まっているか。
- JSON 設定ファイルを触る変更:
  - `jsonStore` を経由しているか（生の `fs.writeFile` を使っていないか）。
  - 壊れ JSON 時に `.bak` が正しく作られるか（`jsonStore` のテストで担保）。
- ルーティング/画面追加:
  - `App.tsx` では原則 `React.lazy` + `Suspense` で route 単位にチャンクを分ける。

---

## 5. 今後の拡張候補（メモ）

- **テスト**
  - `test:unit` の範囲を、投稿フロー / AutoEngagement / Schedule 周りにも段階的に拡大。
  - E2E（Playwright など）で「予約〜実行」の一連確認を自動化。
  - Phase19-B で最小 E2E スモークを追加:
    - `npm run test:e2e:smoke`
    - `npm run test:e2e:smoke:ui`（ライセンス解除済み環境でサイドバー必須）
    - 実施内容:
      - Electron 起動 → 初期UI（サイドバーまたはライセンスモーダル）表示確認
      - サイドバーが表示される環境では `ダッシュボード` / `自動運用` / `投稿ログ` への遷移と主要見出し表示を確認
  - Phase20-B で拡張 E2E フローを追加:
    - `npm run test:e2e:flow`
    - `npm run test:e2e:flow:ui`
    - サイドバー表示環境では `設定` 画面の運用導線ボタン（トラブルシュート/最終サマリ/リリース前チェック）存在まで確認
    - 実績: ライセンス解除済み環境で `test:e2e:flow:ui` 1回通過（UI必須モード）

- **パフォーマンス**
  - Overview の AI 関連やメディアプレビューも、必要に応じてさらにチャンク分割検討。
  - `userMessages.ts` の判定ロジックを、より小さいモジュールに分解して用途別に import する余地あり。
  - Phase19-A で `OverviewPage` に `[perf][overview:mount] total ...ms` を追加済み。初期描画改善の継続計測を行う。
  - Phase19-A 追加: `AutoEngagementPage` に `[perf][auto-engagement:mount] total ...ms`、`PostLogsPage` に `[perf][post-logs:mount] total ...ms` を追加済み。
  - Phase19-A 続き: `AutoEngagementPage` のブロック理由計算 / `enabledAccountIds` Set 生成を `useMemo` 化し、更新関数を `useCallback` 化。`PostLogsPage` の選択整合チェックも `validLogIds` を `useMemo` 化。

- **運用ドキュメント**
  - 障害種別ごと（DBマイグレーション失敗 / LICENSE サーバー / X API まわり）に、`troubleshoot_*.md` を追加していくとオンボーディングが楽になる。
  - Phase20-A で `docs/quality_gate_routine.md` を追加し、`preflight + e2e` の実行ルールを固定。

---

このファイルを入口にすれば、「どこを見れば何が分かるか」が一通り分かる状態になっています。  

## 6. Phase19-A 計測記録テンプレート

目的: 画面マウント計測ログを毎回同じ形式で残し、改善/悪化を比較可能にする。

### 計測対象ログ

- `[perf][overview:mount] total ...ms`
- `[perf][auto-engagement:mount] total ...ms`
- `[perf][post-logs:mount] total ...ms`

### 記録ルール

- 各画面を 3 回開いて計測する。
- 3 値の中央値を「今回値」とする。
- 前回中央値がある場合、`(今回中央値 - 前回中央値) / 前回中央値 * 100` で悪化率を計算する。
- 悪化率が **+20% 以上** の場合は「要調査」。

### 記録フォーマット（コピペ用）

```txt
[date] YYYY-MM-DD
[env] local / staging / release-build

overview:mount
- run1: ___ ms
- run2: ___ ms
- run3: ___ ms
- median: ___ ms
- prev-median: ___ ms (optional)
- delta: ___ % (optional)
- judgment: ok / investigate

auto-engagement:mount
- run1: ___ ms
- run2: ___ ms
- run3: ___ ms
- median: ___ ms
- prev-median: ___ ms (optional)
- delta: ___ % (optional)
- judgment: ok / investigate

post-logs:mount
- run1: ___ ms
- run2: ___ ms
- run3: ___ ms
- median: ___ ms
- prev-median: ___ ms (optional)
- delta: ___ % (optional)
- judgment: ok / investigate

notes:
- 例) 初回のみキャッシュ未温存で +15ms
- 例) 重いログデータ投入時に post-logs が増加
```

### 初回ベースライン（現時点）

- 計測日: 2026-03-27（dev / React Strict Mode）
- 集計ルール:
  - 1回の画面表示で 2 本ログが出るため、各回は「2 本の中央値」で代表値化。
  - その代表値 3 回分の中央値を初回ベースラインとする。
- `overview:mount`
  - run1: 186.5ms（181.5, 191.5）
  - run2: 95.4ms（92.3, 98.4）
  - run3: 89.5ms（86.4, 92.6）
  - baseline median: 95.4ms
- `auto-engagement:mount`
  - run1: 162.9ms（162.0, 163.7）
  - run2: 52.6ms（51.9, 53.3）
  - run3: 52.1ms（51.3, 52.9）
  - baseline median: 52.6ms
- `post-logs:mount`
  - run1: 12.2ms（11.8, 12.6）
  - run2: 27.4ms（26.9, 27.9）
  - run3: 35.5ms（34.9, 36.1）
  - baseline median: 27.4ms
- 参考（既存ログで確認済み）
  - `[perf][maintenance:startup] total 10ms`

### 次回採取手順（3分）

1. 開発アプリを起動し、Overview / AutoEngagement / PostLogs をそれぞれ 3 回表示する。
2. コンソールに出る以下ログを控える。
   - `[perf][overview:mount] total ...ms`
   - `[perf][auto-engagement:mount] total ...ms`
   - `[perf][post-logs:mount] total ...ms`
3. 上のテンプレートへ run1-run3 と中央値を記録する。
