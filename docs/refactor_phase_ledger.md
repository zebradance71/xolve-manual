# Refactor Phase Ledger（1-20）

目的: Phase 1-20 で「何をやったか」を時系列で追える最終台帳。

## 進捗一覧

| Phase | 状態 | 主な実施内容 |
|---|---|---|
| 1 | 完了 | 設定まわりの基盤整理（定数一元化、Settings 分割の土台） |
| 2 | 完了 | JSON ストア共通化の着手、I/O 重複削減 |
| 3 | 完了 | Main 側 usecase 分離、責務境界の明確化 |
| 4 | 完了 | Settings ロジックを hook 単位に分割 |
| 5 | 完了 | ドメインルール（validate/sanitize）整備 |
| 6 | 完了 | 設定初期化の perf 計測導入（`[perf][settings:init]`） |
| 7 | 完了 | スモーク検証をユニットテストへ移行 |
| 8 | 完了 | テスト・設定の安定化（Vitest 対応） |
| 9 | 完了 | preflight 導線の整備 |
| 10 | 完了 | 完了条件（DoD）と運用チェックの固定化 |
| 11 | 完了 | 実運用向けの補助スクリプト/ドキュメント整備 |
| 12 | 完了 | `SettingsPage` の lazy 化（パネル分割ロード） |
| 13 | 完了 | ルート分割方針の展開 |
| 14 | 完了 | `AccountsPage` 抽出 + route lazy load |
| 15 | 完了 | `OverviewPage` 抽出 + route lazy load |
| 16 | 完了 | `SchedulesPage` 抽出 + route lazy load |
| 17 | 完了 | エラーメッセージ分割（`appModeMessages` / `postLogMessages`） |
| 18 | 完了 | 最終サマリ/ガイド系 docs 整備（A/B/C） |
| 19 | 完了 | perf 計測運用、E2E smoke、運用導線 UI/IPC 整備（A/B/C） |
| 20 | 完了 | quality gate routine と E2E flow 拡張（A/B） |

## 実績ログ（最終）

- `npm run test:e2e:flow:ui` 実行済み（ライセンス解除済み環境、pass）
- `npm run quality:gate` 実行済み（`test:unit` / `build` / `test:e2e:smoke`、pass）

## 参照ドキュメント

- `docs/refactor_final_summary.md`
- `docs/release_preflight_checklist.md`
- `docs/quality_gate_routine.md`
- `docs/troubleshoot_guide.md`
