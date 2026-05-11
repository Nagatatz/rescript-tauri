# Tasklist: 予約語回避 suffix を polymorphic variant に置換

> **設計の確定**: ReScript 12 で polymorphic variant タグに `@as(N)` を付けると `.resi` で "Unused attribute" warning が出る (warning 101)。実装時に確認し、**`@unboxed` regular variant + `@as(N)`** に切り替えて以下を実装した（design.md 参照）。最終的に `LogLevel.Trace` / `Importance.None` / `Visibility.Private` 等の constructor 名で公開し、runtime は素の int。

## Phase 0: 準備

- [x] `EnterWorktree` で worktree `replace-suffix-with-poly-variant` を作成
- [x] ローカル main を merge して steering 020 を取り込み

## Phase 1: PluginLog 置換

- [x] `PluginLog.res` で `module LogLevel = { @unboxed type t = | @as(1) Trace | ... }` を実装
- [x] `PluginLog.resi` を同期
- [x] `recordPayload.level` の型を `int` → `LogLevel.t`
- [x] `tests/runtime/plugin_log.test.mjs` から LogLevel 定数アサーションを削除、levels テーブルを数値直書きに
- [x] `tests/plugin_log_signature.res` を更新（`_check_` を新 API に）
- [x] `pnpm --filter @rescript-tauri/plugin-log build && test` → 8 passed

## Phase 2: PluginNotification 置換

- [x] `module Importance` / `module Visibility` を `@unboxed` variant に置換
- [x] `PluginNotification.resi` を同期
- [x] `options.visibility?` / `channel.importance?` / `channel.visibility?` の型を `int` → `Importance.t` / `Visibility.t`
- [x] `tests/runtime/plugin_notification.test.mjs` から Importance / Visibility 定数アサーション describe を削除
- [x] `tests/plugin_notification_signature.res` を更新
- [x] `pnpm --filter @rescript-tauri/plugin-notification build && test` → 19 passed

## Phase 3: PluginOs 置換

- [x] `PluginOs.res` の `external osType_` を削除、`module OsType = { external get: unit => osType = "type" }` を追加
- [x] `PluginOs.resi` を同期
- [x] `tests/runtime/plugin_os.test.mjs` の `PluginOs.osType_()` → `PluginOs.OsType.get()`
- [x] `tests/plugin_os_signature.res` を更新
- [x] `pnpm --filter @rescript-tauri/plugin-os build && test` → 10 passed

## Phase 4: 全体検証

- [x] `pnpm --recursive build` 成功
- [x] `pnpm --recursive test` 全件 pass (268 件: core 182, plugin-fs 14, plugin-dialog 10, plugin-clipboard-manager 7, plugin-shell 8, plugin-http 3, plugin-log 8, plugin-notification 19, plugin-os 10, schema 7)
- [x] biome check (touched files) pass — `--write` で自動修正済み
- [x] 公開 API から `_` suffix 完全消滅を確認（packages/plugin-{log,notification,os}/src/, examples/plugin-{log,notification,os}-demo/, sphinx-docs/user/plugin-{log,notification,os}.md, docs/repository-structure.md）

## Phase 5: ドキュメント

- [x] `packages/plugin-log/{README,CHANGELOG}.md` 更新
- [x] `packages/plugin-notification/{README,CHANGELOG}.md` 更新
- [x] `packages/plugin-os/{README,CHANGELOG}.md` 更新
- [x] `sphinx-docs/user/plugin-log.md` 例コード更新（"Numeric LogLevel constants" → "LogLevel.t variant"）
- [x] `sphinx-docs/user/plugin-notification.md` 例コード更新（"Numeric enum constants" → "Importance / Visibility variants"）
- [x] `sphinx-docs/user/plugin-os.md` 例コード更新（"type() renamed to osType_()" → "type() lives under the OsType submodule"）
- [ ] `sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-{log,notification,os}.po` — **本ステアリング外**。`make update-po` で機械生成すべきで、 `b57ad6c` "Refresh .po files after note refactor" と同様の独立フォローアップでカバーする
- [x] `docs/repository-structure.md` の plugin-log / plugin-notification / plugin-os 説明欄を更新
- [x] `examples/plugin-{log,notification,os}-demo` の `src/App.res` を新 API に追従
- [x] `examples/plugin-{log,notification,os}-demo` の `README.md` を新 API に追従

## Phase 6: コミット

- [x] 機能単位でコミット:
  - 💥 Replace PluginLog.LogLevel int module with @unboxed level variant
  - 💥 Replace PluginNotification.{Importance,Visibility} with @unboxed variants
  - 💥 Rename PluginOs.osType_ to OsType.get
  - 📝 Update docs / examples for suffix removal

## Phase 7: マージ

- [x] `tasklist.md` の全タスクを `[x]` に更新（マージタスク自体含む）してコミット
- [ ] `AskUserQuestion` でユーザーに main マージ可否を確認
- [ ] 承認後、main マージ → worktree 削除 → ブランチ削除 を一括実行
- [ ] クリーンアップ完了の検証

## フォローアップ（別 steering）

- **sphinx-docs/locale/ja/LC_MESSAGES/user/*.po refresh**: `make update-po` で plugin-log / plugin-notification / plugin-os の翻訳ファイルを再生成。現状は本 steering の .md 編集により .po の msgid が部分的に stale だが、サイトビルドには影響しない（fallback で英語が使われる）。`b57ad6c` "Refresh .po files after note refactor" のパターンで独立コミット化する
