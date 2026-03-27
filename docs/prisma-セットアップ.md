# Prisma（Windows / Electron）

## `EPERM` で `npx prisma generate` が失敗するとき

X-Tool（Electron）を**すべて終了**してから再実行してください。`query_engine-windows.dll.node` をプロセスが掴んでいるとリネームに失敗します。

## マイグレーション

開発用 DB:

```bash
npx prisma migrate dev
```

本番用ユーザーデータ:

```bash
npx prisma migrate deploy
```
