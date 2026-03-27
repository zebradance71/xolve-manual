# Refactor Phase1 Checklist

目的: 今の挙動を壊さず、設定まわりを読みやすく・直しやすくする

## 0. 安全ネット固定

- [x] 手動スモーク確認項目を固定（投稿、予約、CSV、自動運用、設定保存）
- [x] `npm run build` を実行ゲート化（各ステップ完了時に実施）
- [x] 最低限スモークテスト（自動）を作成（`npm run smoke:json-store`）

### 手動スモーク手順（固定）

- [x] 設定保存（全般）: 値変更 -> 保存 -> 再起動後に保持確認
- [x] 設定保存（ライセンス）: キー更新/再認証/解除の動作確認
- [x] 設定保存（AIモデル）: プリセット適用/詳細保存の反映確認
- [x] 予約作成: 新規予約保存 -> 一覧表示/実行待ち状態確認
- [x] 今すぐ投稿: 手動投稿の実行とエラー未発生確認
- [x] CSV読込: CSV投入 -> パース成功/エラー表示妥当性確認
- [x] 起動時メンテ: 起動直後に例外が出ないことをログで確認

#### 起動時メンテ確認ログ（固定）

- 有効時に確認するログ
  - `[maintenance:startup] enabled`
  - `[media-cache:startup] maintenance started`
  - `[media-cache:startup] maintenance completed ...`
  - `[retention:startup] started`
- 無効時に確認するログ
  - `[maintenance:startup] disabled`

## 2. 設定キー・既定値の一元化

- [x] `src/shared/config/appDefaults.ts` を追加
- [x] 全般設定デフォルト（日時フォーマット、テーマ、AI文字数、AIログ保存、NGワード、段階フォールバック）を集約
- [x] メンテナンス既定値・下限値を集約
- [x] AIモデル型/既定値を集約
- [x] Main 側ストアのハードコードを共通定数参照へ置換

## 3. Settings 画面の分割

- [x] `SettingsPage` の巨大 JSX をパネルに分離
- [x] `GeneralSettingsPanel` / `LicenseSettingsPanel` / `ApiSettingsPanel` を導入
- [x] `types.ts` を導入して型を整理
- [x] 既存機能（保存、再認証、解放、保守実行、AIプリセット適用）の挙動維持
- [x] 追加整理: `useSettingsController` にハンドラ群を切り出し

## 4. IPC 呼び出しの薄いラッパ統一

- [x] `src/renderer/lib/settingsApi.ts` を追加
- [x] `maintenance:*` / `aiModel:*` / `license` の呼び出しをラップ
- [x] UI層から IPC 文字列の直書きを削減
- [x] `no handler` 文言ヒントを共通化

## 5. JSON ストア共通ユーティリティ化（軽量）

- [x] `src/main/jsonStore.ts` を追加
- [x] atomic write を共通化
- [x] 壊れ JSON の `.bak` 退避を共通化
- [x] read fallback（default + normalize）を共通化
- [x] `maintenanceConfigStore` / `aiModelConfigStore` の重複 I/O を削除

## ビルドゲート記録

- [x] Step2/3 反映後: `npm run build` 成功
- [x] Step4 反映後: `npm run build` 成功
- [x] Step5 反映後: `npm run build` 成功
- [x] 手動スモーク（投稿、予約、CSV、自動運用、設定保存）完了
- [x] 最低限自動スモーク（`npm run smoke:json-store`）完了

## Phase1 DoD 状態

- [x] `SettingsPage.tsx` の責務縮小
- [x] `npm run build` 通過
- [x] チェックリスト全項目 OK
- [x] 既存機能の挙動変更なし（手動スモーク完了で確定）
