## 戻したいとき（この変更セットの取り消し）

このワークスペースは git 管理ではないため、差分を小さく保つ方針で実装しています。
不具合があれば、以下を戻すだけで「元の CSV 動画プレビュー未対応（file://）状態」へ概ね復帰できます。

### 1) 新規追加ファイルを削除
- `src/main/xtoolMediaCache.ts`
- `src/main/xtoolMediaUrl.ts`
- `src/main/xtoolMediaProtocol.ts`

### 2) 既存ファイルの差分を戻す
- `src/main/main.ts`
  - `protocol.registerSchemesAsPrivileged([...xtool-media...])` を削除
  - `registerXtoolMediaProtocol()` 呼び出しを削除
  - `protocol` import と `registerXtoolMediaProtocol` import を削除
  - `maintainXtoolMediaCache()` の呼び出しと import を削除
- `src/main/scheduleHandlers.ts`
  - `cacheMediaFile` / `encodePathToXtoolMediaUrl` の import を削除
  - `resolveCsvMediaForRow` 内の「cacheして xtool-media URL にする」部分を削除し、元の `pathToFileURL(abs)` に戻す
  - `previewMediaPaths` の動画を `m.url` にしている部分を元の `toPreviewUrl(...)` に戻す
  - サイズ上限チェック（`CSV_MAX_VIDEO_BYTES` / `CSV_MAX_TOTAL_MEDIA_BYTES`）を削除
- `src/main/scheduleRunner.ts`
  - `decodeXtoolMediaUrl` import と `xtool-media://` 分岐を削除
  - `MEDIA_TOO_LARGE` のサイズチェックを削除
- `vite.renderer.config.ts`
  - CSP の `media-src` から `xtool-media:` を削除

### 3) 影響範囲（この変更で触っている仕様）
- CSVインポートの `mediaJson.url` が `file://` から `xtool-media://` になり、投稿実行時は decode してローカルパスに戻します
- CSVプレビューの「動画」は `xtool-media://` になります（画像は従来通り data URL 優先）

