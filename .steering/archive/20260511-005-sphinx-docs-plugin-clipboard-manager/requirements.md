# Steering 20260511-005 — Requirements

## 目的

`sphinx-docs/user/plugin-clipboard-manager.md` を新設し、`@rescript-tauri/plugin-clipboard-manager` のエンドユーザー向け公開ガイドを提供する。`plugin-fs.md` / `plugin-dialog.md` / `plugin-notification.md` の既存スタイル踏襲。

## 背景

- パッケージ実装は steering 057 (2026-05-09) で完了済み。`packages/plugin-clipboard-manager/README.md` は存在するが、エンドユーザー向け公開ガイド（sphinx-docs）が未整備。
- `installation.md` の note 句で `plugin-clipboard-manager` のユーザーガイドが「後続 sub-steering で追加予定」と明記済み（74-83 行）。本 steering でその約束を回収する。

## スコープ

### In-scope

- 新規ファイル: `sphinx-docs/user/plugin-clipboard-manager.md`
- `sphinx-docs/user/index.md` の Phase 2 テーブルとtoctree への `plugin-clipboard-manager` 追加
- `sphinx-docs/user/installation.md` の note 句から `plugin-clipboard-manager` を除外（ガイド完成パッケージリストへ移動）

### Out-of-scope

- 日本語 (.po) 翻訳。`locale/ja/` は別 steering で対応。
- `examples/plugin-clipboard-manager-demo/` の作成。
- `packages/plugin-clipboard-manager/README.md` の更新（README は既に十分）。

## 公開 API カバレッジ

ガイドは以下 6 関数 + 1 record をすべてカバーすること:

| Symbol | Returns | Notes |
|---|---|---|
| `writeText(text, ~opts=?)` | `promise<unit>` | `writeTextOptions.label` は Android entity name |
| `readText()` | `promise<string>` | プレーンテキスト読み込み |
| `writeImage('image)` | `promise<unit>` | polymorphic union 受け流し |
| `readImage()` | `promise<RescriptTauriCore.Image.t>` | core の Image.t を直接利用 |
| `writeHtml(html, ~altText=?)` | `promise<unit>` | リッチテキストコピーの典型用途 |
| `clear()` | `promise<unit>` | Android < SDK 28 は空文字書き込みに fallback |
| `writeTextOptions` | record `{label?: string}` | — |

## Image.t 連携の明示

`readImage` は `RescriptTauriCore.Image.t` を返し、`writeImage` も `Image.t` を受け取れる。これは plugin-fs の `BaseDirectory` 再利用パターンと同じく **peerDep 経由で core モジュールを再利用**しており、plugin-clipboard-manager 独自の Image 型は持たない。ガイドは以下を明示する:

- 「Image 型は `@rescript-tauri/core` の `Image.t` を直接利用する」旨を冒頭または該当節で説明
- `Core.Image.fromBytes` / `Core.Image.fromPath` を image 入手手段として案内（cross-ref または external link）
- `Image.rgba` で読み取った bytes を取り出す例

## polymorphic `'image` 引数

`writeImage` は upstream union (`string | Image | Uint8Array | ArrayBuffer | number[]`) を polymorphic `'image` で受け流すため、呼び出し側で型注釈や 2 つの実例（`Image.t` を渡す / `Uint8Array` を渡す）を示すこと。

## Rust 側 permission

最小 capability 例として `clipboard-manager:default` を含む JSON を提示する（plugin-fs / plugin-dialog ガイドと同形）。

## 受け入れ基準

- 新規ガイドが既存 plugin ガイドと同じスタイル（`{note}` ブロック / Install / Capabilities / Public API / See also）
- `installation.md` から `plugin-clipboard-manager` のクロスリンクが解決する
- `Core.Image` への参照リンク（sphinx 内 cross-ref が無ければ GitHub の `packages/core/src/Image.resi` への external link）が壊れていない
- `pnpm run check` が pass する
