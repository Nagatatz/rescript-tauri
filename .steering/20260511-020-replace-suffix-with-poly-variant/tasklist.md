# Tasklist: 予約語回避 suffix を polymorphic variant に置換

## Phase 0: 準備

- [ ] `EnterWorktree` で worktree `replace-suffix-with-poly-variant` を作成
- [ ] ローカル main を merge して steering 020 を取り込み

## Phase 1: PluginLog 置換

- [ ] `PluginLog.res` の `module LogLevel` を削除、`type level = @unboxed | @as(1) Trace | ...` を追加
- [ ] `PluginLog.resi` を同期
- [ ] `recordPayload.level` の型を `int` → `level`
- [ ] `tests/runtime/plugin_log.test.mjs` から LogLevel 定数アサーションを削除、levels テーブルを数値直書きに
- [ ] `tests/plugin_log_signature.res` を更新（`_check_` を新 API に）
- [ ] `pnpm --filter @rescript-tauri/plugin-log build && test` で確認

## Phase 2: PluginNotification 置換

- [ ] `PluginNotification.res` の `module Importance` / `module Visibility` を削除、`@unboxed` variant 2 つを追加
- [ ] `PluginNotification.resi` を同期
- [ ] `options.visibility?` / `channel.importance?` / `channel.visibility?` の型を更新
- [ ] `tests/runtime/plugin_notification.test.mjs` から Importance / Visibility 定数アサーションを削除
- [ ] `tests/plugin_notification_signature.res` を更新
- [ ] `pnpm --filter @rescript-tauri/plugin-notification build && test` で確認

## Phase 3: PluginOs 置換

- [ ] `PluginOs.res` の `external osType_` を削除、`module OsType = { external get: ... }` を追加
- [ ] `PluginOs.resi` を同期
- [ ] `tests/runtime/plugin_os.test.mjs` の `PluginOs.osType_()` → `PluginOs.OsType.get()`
- [ ] `tests/plugin_os_signature.res` を更新
- [ ] `pnpm --filter @rescript-tauri/plugin-os build && test` で確認

## Phase 4: 全体検証

- [ ] `pnpm --recursive build` 成功
- [ ] `pnpm --recursive test` 全件 pass
- [ ] biome check (touched files) pass
- [ ] `grep -rE "(osType_|error_|warn_|info_|debug_|default_|private_|public_)" packages/plugin-{log,notification,os}/src/` で出力空（公開 API から完全に消えた確認）

## Phase 5: ドキュメント

- [ ] `packages/plugin-log/{README,CHANGELOG}.md` 更新
- [ ] `packages/plugin-notification/{README,CHANGELOG}.md` 更新
- [ ] `packages/plugin-os/{README,CHANGELOG}.md` 更新
- [ ] `sphinx-docs/user/plugin-log.md` 例コード更新
- [ ] `sphinx-docs/user/plugin-notification.md` 例コード更新
- [ ] `sphinx-docs/user/plugin-os.md` 例コード更新
- [ ] `sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-{log,notification,os}.po` 対応箇所更新
- [ ] `docs/repository-structure.md` の plugin 説明欄を更新
- [ ] `examples/plugin-log-demo` / `plugin-notification-demo` / `plugin-os-demo` のサンプルコード更新（存在する場合）

## Phase 6: コミット

- [ ] 機能単位でコミット:
  - 💥 ✨ Replace PluginLog.LogLevel int module with @unboxed level variant
  - 💥 ✨ Replace PluginNotification.{Importance,Visibility} with @unboxed variants
  - 💥 ✨ Rename PluginOs.osType_ to OsType.get
  - 📝 Update docs (README / CHANGELOG / sphinx) for suffix removal
  - ♻️ Update examples for new variant-based APIs (該当する場合)

## Phase 7: マージ

- [ ] `tasklist.md` の全タスクを `[x]` に更新（マージタスク自体含む）してコミット
- [ ] `AskUserQuestion` でユーザーに main マージ可否を確認 (本ステアリングは事前承認は無いので確認必須)
- [ ] 承認後、main マージ → worktree 削除 → ブランチ削除 を一括実行
- [ ] クリーンアップ完了の検証
