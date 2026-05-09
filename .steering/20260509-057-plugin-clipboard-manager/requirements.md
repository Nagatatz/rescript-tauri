# 要件定義: `@rescript-tauri/plugin-clipboard-manager`

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-057-plugin-clipboard-manager` |

## 1. ゴール

`@tauri-apps/plugin-clipboard-manager` v2.3.2 (108 行 / 7 export — 6 関数 + 1 型 import) の **stable public surface 100%** を独立パッケージとして提供。

## 2. 対象 API

**関数 (6):**
- `writeText(text, ~opts=?)` — `{label?: string}`
- `readText() → string`
- `writeImage('image)` — polymorphic（string / Image.t / Uint8Array / ArrayBuffer / array<int>）
- `readImage() → Image.t`
- `writeHtml(html, ~altText=?)`
- `clear()`

**依存:** `RescriptTauriCore.Image.t`（既存 core モジュールを peerDep 経由で再利用）

## 3. 完了条件

- 100% シンボルカバー
- 専用 CI 2 件 + matrix + release.yml
- ドキュメント更新
- monorepo build + test 全件 pass
