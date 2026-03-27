# Troubleshoot Guide（障害時の早見表）

目的: 典型的な障害が起きたときに「どのログを見るか」「どう対処するか」を素早く判断できるようにする。

---

## 1. 起動時エラー・設定画面が開かない

### 1-1. アプリ起動直後に例外が出る / メンテログがおかしい

- **症状**
  - 起動直後にエラーダイアログが出る。
  - ログに `maintenance` 周りの例外が出ている。
- **見るポイント**
  - ログに以下が出ているか:
    - `[maintenance:startup] enabled` または `disabled`
    - `[perf][maintenance:startup] total ...ms`
  - `maintenanceConfig.json` / `aiModelConfig.json` 付近で JSON パースエラーがないか。
- **対処**
  1. `npm run test:unit` を実行し、`maintenanceConfig` / `aiModelConfig` テストが通るか確認。
  2. `npm run preflight:release` を実行し、jsonStore 周りでエラーがないか確認。
  3. それでも再現する場合は、壊れた設定ファイルが `.bak` 退避されているかを確認し、必要であれば削除して既定値から再生成する。

---

## 2. ライセンス周りのトラブル

### 2-1. ライセンス認証に失敗する / ロックされたまま

- **症状**
  - ライセンス入力モーダルでエラー表示が出続ける。
  - 「このキーは別のPCで使用されています」などの文言が出る。
- **見るポイント**
  - `App.tsx` の `check-license` IPC 呼び出しのログ（Main 側）。
  - `userMessages.ts` 経由の `licenseReleaseCatchMessage` 文言。
- **対処**
  1. `.env` などに `SUPABASE_URL` / `SUPABASE_ANON_KEY` が正しく設定されているか確認。
  2. ライセンスキー入力欄の値が余分な空白を含んでいないか確認（コピー時の前後スペースなど）。
  3. エラー内容に「MACHINE_MISMATCH」「MACHINE_ASSIGN_FAILED」「SUPABASE_UNAVAILABLE」が含まれている場合、それぞれの意味に応じてサーバー側設定または PC 側の再登録を行う。

---

## 3. X 投稿・自動運用まわりのエラー

### 3-1. 今すぐ投稿 / 予約投稿が失敗する

- **症状**
  - 「今すぐ投稿」ボタンでエラーが出る。
  - 予約作成時にトーストでエラーが表示される。
- **見るポイント**
  - Post ログ一覧（`PostLogsPage`）のステータスとエラーメッセージ。
  - `userMessages.ts` の `toUserFacingMessage` でどの文言に変換されているか。
  - X API エラーコード（HTTP 401/403/429 など）。
- **対処**
  1. `AccountsPage` で対象アカウントの OAuth キー／トークンが正しいか、空欄でないか確認。
  2. エラーメッセージに「認証」「forbidden」「rate limit」などが含まれる場合、`userMessages.ts` の対応するメッセージを参照し、API プラン・残高・権限設定を確認。
  3. ネットワークエラー（`ENOTFOUND` / `ETIMEDOUT` など）の場合は、プロキシ設定と OS のネットワーク接続を確認。

### 3-2. AutoEngagement が動かない / シミュレーションだけ動く

- **症状**
  - AutoEngagement 設定を保存しても実際の自動運用が走らない。
  - シミュレーションは動くが、本番運用が動かない。
- **見るポイント**
  - `AUTO_ENGAGEMENT_PER_ACCOUNT.md` の仕様（アカウント単位の有効化条件）。
  - `useAutoEngagement.ts` の `MSG_APP_MODE_REQUIRED` エラー（アプリモード以外で呼んでいないか）。
  - Worker ログパネルにエラーが出ていないか。
- **対処**
  1. 対象アカウントに必要な X API / OAuth 情報が登録されているか確認。
  2. AutoEngagement のスコープ（シミュレーション / 本番）が意図通りかを画面上で確認。
  3. `MSG_APP_MODE_REQUIRED` が出ている場合は、ビルド済みアプリから実行しているかを確認（ブラウザ単体等で開いていないか）。

---

## 4. 予約カレンダー / CSV まわりのトラブル

### 4-1. スケジュール画面が空 / エラーになる

- **症状**
  - `/schedules` 画面が読み込み中のまま / 空表示になる。
  - 予約一覧が表示されない。
- **見るポイント**
  - `ScheduleCalendarPanel.tsx` と `useScheduleCalendar.ts` のログ。
  - `MSG_APP_MODE_REQUIRED` の有無（アプリモードで動いているか）。
  - Prisma エラー（`p2022` / `does not exist in the current database`）の有無。
- **対処**
  1. `npm run prisma:migrate` で DB スキーマが最新か確認。
  2. それでも `p2022` 系エラーが出る場合は、`troubleshoot_guide.md` と `userMessages.ts` の Prisma 関連メッセージを参照し、アプリの再起動・再ビルドを検討。

### 4-2. CSV 読み込みでエラーになる / 一部メディアがプレビューされない

- **症状**
  - CSV 読み込み時にエラー表示が出る。
  - メディアパス付き行の一部がプレビューされない。
- **見るポイント**
  - CSV フォーマット（列順・ヘッダー名）が期待どおりか。
  - パスに余計な空白や不正な拡張子（4件超のメディアなど）がないか。
  - `OverviewPage.tsx` の CSV 取り込み部分で例外が出ていないか。
- **対処**
  1. サンプル CSV で再現しないか確認（問題なければ入力 CSV 側の形式を見直す）。
  2. 再現する場合は該当行のテキスト・メディアパスを最小ケースに絞ってデバッグする。

---

## 5. どうしても原因が分からないとき

1. `npm run test:unit` と `npm run preflight:release` を必ず一度通す。
2. ログから以下のキーワードを探す:
   - `ERR_` / `INVALID_` / `maintenance:` / `aiModel:` / `license` / `AUTO_ENGAGEMENT`
3. メッセージが英語だらけで読みにくい場合は `userMessages.ts` の `toUserFacingMessage` を参照し、「どの系統のエラー」として扱われているかを見る。
4. それでも判断がつかない場合は、関連しそうなモジュール（usecase / hooks / ui コンポーネント名）と一緒にログをメモして、Issue やサポート用チャンネルに貼る。
5. 外部仕様変更が疑われる場合は、`docs/external_spec_changes.md` に「何が変わったか」「暫定回避策」を即時記録する。

## 6. E2E実行メモ（運用記録）

- 実施日: 2026-03-26
- コマンド: `npm run test:e2e:flow:ui`
- 結果: pass（ライセンス解除済み環境）
- 要点: サイドバー表示を必須条件にして、`ダッシュボード` / `自動運用` / `投稿ログ` / `設定` の遷移と、設定画面の運用導線ボタン表示まで確認済み。
- 追加実績:
  - コマンド: `npm run quality:gate`
  - 結果: pass（`test:unit` / `build` / `test:e2e:smoke`）
  - 補足: `e2e-smoke-electron: ok (sidebar=no, licenseModal=yes, requireSidebar=no)` を確認。
