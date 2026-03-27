# 自動運用のアカウント別上限・本日カウント

## 単一の「正」（ソース・オブ・トゥルース）

- **本日の like / follow / reply の件数**は **`AutoEngagementAccountDayStats`（Prisma / DB）** を正とする。
- メインプロセスの Runner は **DB を更新したうえで**、遅延を減らすため **メモリ**（`accountAutoEngagementStats.ts`）に同期する。表示・集約は DB またはそのスナップショットに揃える。

## 上限の解決順

1. `Account.autoDailyLikeLimit` / `autoDailyFollowLimit` / `autoDailyReplyLimit` が **非 null** ならその値。
2. さもなければ `AutoEngagementConfig` の共通 `dailyLikeLimit` / `dailyFollowLimit` / `dailyReplyLimit`。

IPC のアカウント DTO と `fetchAutoEngagementAccountStatsForSnapshot` で、UI 向けに **解決済みの数値**（`AutoEngagementAccountDayStatDTO.daily*`）も載せる。

## 集約フリーズ（複数アカウント）

- `buildAutoEngagementAggregateFreezeStatus({ onlyAccountIds? })`（`autoEngagementFreezeAggregate.ts`）が、対象アカウントの DB 行を合算し `FreezeGuardStatus` 相当を返す。
- `onlyAccountIds` は **設定の「実行アカウント」**（`enabledAccountIds`）に合わせる。シミュで未選択のときは「全アカウント」と同じ扱い（worker / Runner と整合）。

## 変更時のチェックリスト

アカウント別上限やカウント周りを触るときは、次を **まとめて** 確認する。

1. **Prisma**: `schema.prisma` と **マイグレーション SQL**（列追加・インデックス等）
2. **`npx prisma generate`**（Electron 実行中は DLL ロックで失敗しうる → アプリ終了後）
3. **IPC**: `accountTypes` / `accountHandlers`（一覧・更新 DTO）
4. **メイン**: `accountAutoEngagementStats`・Runner・`workerStatusStream`・リセット系ハンドラ
5. **UI**: `AutoEngagementPage`（共通上限・アカウント別入力・バッジ）

## リセット

「本日リセット」は **アカウント別 DB 行**（当日分）と、従来の **freezeGuard 全体カウンタ**の両方をクリアする想定で揃える（文言・実装のずれに注意）。
