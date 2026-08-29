# Requirements: sphinx-docs/user/plugin-log.md

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-003 |
| パッケージ | `@rescript-tauri/plugin-log` |
| 目的 | エンドユーザー向けの公開ドキュメント (`sphinx-docs/user/plugin-log.md`) を追加し、`installation.md` の "Dedicated user guides ... scheduled for follow-up" note から plugin-log を外す |

## 背景

- `packages/plugin-log/` は steering 055 で実装済み。100% カバレッジ・README・CHANGELOG は揃っている。
- `sphinx-docs/user/` には `plugin-fs.md` / `plugin-dialog.md` / `plugin-notification.md` / `schema.md` の 4 ガイドが存在するが、plugin-log のガイドは未追加。
- `installation.md` の `pnpm add @rescript-tauri/plugin-log` コマンドは既にあり、文末 note でフォローアップ予定として明記されている。
- ja 翻訳 .po は別 sub-steering に分離。本作業では英語版 `.md` のみ追加する。

## 機能要件

1. **公開ドキュメント追加**: `sphinx-docs/user/plugin-log.md` を新規作成
   - Status / Install / Capabilities / Minimal example / Public API / Compatibility / See also の 7 セクション
   - 既存 `plugin-fs.md` / `plugin-dialog.md` の文体・構造に準拠
2. **公開 API カバレッジ**: `PluginLog.resi` の全シンボルを表で網羅
   - 5 log 関数: `error` / `warn` / `info` / `debug` / `trace`
   - 2 stream 関数: `attachLogger` / `attachConsole`
   - `LogLevel` 数値定数: `trace` / `debug_` / `info_` / `warn_` / `error_`
   - 3 型: `logOptions` / `recordPayload` / `unlisten`
3. **ReScript 固有事項の明示**
   - `LogLevel` の suffix 付き定数命名理由（`$$debug` / `$$info` / `$$warn` / `$$error` の予約語衝突を避けるため）
   - 各 log 関数の `~options=?: logOptions` の使い方
4. **Rust 側設定例**
   - `Cargo.toml` への `tauri-plugin-log = "2"` 追加
   - `tauri::Builder` での `.plugin(tauri_plugin_log::Builder::new()...)` 登録例
   - `targets()` で複数 sink（stdout / webview / file）を設定する典型パターン
5. **capability 設定**
   - `log:default` permission の例
6. **index.md / installation.md の更新**
   - `index.md` の "Phase 2 packages" 表に plugin-log 行を追加
   - `index.md` の toctree に `plugin-log` を追加
   - `installation.md` の "Dedicated user guides ... follow-up" note から `plugin-log` を外す（残りの 4 plugin はそのまま）
   - 残る note の対象パッケージリストを `{shell,notification,os,clipboard-manager,http}` に更新（http は新規に notice 対象として追加）

## 非機能要件

- `pnpm run check` で Biome 警告が出ないこと（sphinx-docs の `.md` は Biome 対象外なので影響なし）
- `sphinx-docs` ビルドが通ること（手元の Python 環境で `make html` を試みる、または CI に委譲）
- ja 翻訳 .po は更新しない（後続 sub-steering）

## Non-goals

- runnable demo (`examples/plugin-log-demo/`) の追加（CHANGELOG の "Deferred to follow-up sub-steerings" に明示済み、別 steering に分離）
- ja 翻訳 (`.po` ファイル) の更新
- plugin-log 自体の API 拡張・追加
- 他プラグインのユーザーガイド追加（並列 steering で別途進行）

## 受け入れ条件

- [ ] `sphinx-docs/user/plugin-log.md` が新規作成され、上記 6 セクションがすべて存在する
- [ ] `index.md` の Phase 2 packages 表と toctree に plugin-log が含まれる
- [ ] `installation.md` の follow-up note から plugin-log が除外されている
- [ ] `pnpm run check` で diff 由来の警告が出ない
- [ ] `pnpm --recursive build` が成功する（ドキュメント変更のみだが念のため確認）
- [ ] `grep -n "plugin-log" sphinx-docs/user/installation.md` で plugin-log への適切な cross-ref が確認できる
