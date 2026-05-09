# タスクリスト: `@rescript-tauri/plugin-shell` 新規パッケージ

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-051-plugin-shell` |
| ブランチ | `worktree-plugin-shell`（worktree 経由） |

## Phase 0: 準備

- [ ] worktree を作成 (`EnterWorktree plugin-shell`)
- [ ] requirements.md / design.md / tasklist.md をユーザー承認

## Phase 1: パッケージ scaffolding

- [ ] `packages/plugin-shell/package.json`
- [ ] `packages/plugin-shell/rescript.json`
- [ ] `packages/plugin-shell/vitest.config.mjs`
- [ ] `packages/plugin-shell/README.md`
- [ ] `packages/plugin-shell/CHANGELOG.md`
- [ ] `pnpm install` で workspace に取り込み・peerDependency を解決
- [ ] コミット: `🔧 Scaffold @rescript-tauri/plugin-shell package`

## Phase 2: バインディング実装

- [ ] `src/PluginShell.res` / `.resi`
  - [ ] 型: `spawnOptions` / `childProcess<'o>` / `terminatedPayload`
  - [ ] `openPath` 関数
  - [ ] `Command` モジュール（`create` / `createRaw` / `sidecar` / `sidecarRaw` / `spawn` / `execute` / `onClose` / `onError` / `onStdoutData` / `onStderrData` / `removeAllListeners` / `stdout` / `stderr`）
  - [ ] `Child` モジュール（`pid` / `write` / `kill`）
  - [ ] `EventEmitter` モジュール（9 method）
- [ ] `pnpm --filter @rescript-tauri/plugin-shell build` 成功
- [ ] コミット: `✨ Implement @rescript-tauri/plugin-shell bindings`

## Phase 3: テスト

- [ ] `tests/plugin_shell_signature.res` — 全公開シンボルへの型注釈付き呼び出し
- [ ] `tests/runtime/plugin_shell.test.mjs` — `Mocks.mockIPC` で IPC コマンド名検証
- [ ] `pnpm --filter @rescript-tauri/plugin-shell test` 全件 pass
- [ ] コミット: `✅ Add type-level and runtime tests for plugin-shell`

## Phase 4: CI 拡張

- [ ] `.github/workflows/tests-plugin-shell-types.yml` 新設
- [ ] `.github/workflows/tests-plugin-shell-runtime.yml` 新設
- [ ] `.github/workflows/tests-coverage.yml` matrix に `plugin-shell` 追加
- [ ] コミット: `🔧 Add plugin-shell CI workflows and coverage matrix entry`

## Phase 5: ドキュメント更新

- [ ] `docs/repository-structure.md` §2.2 に `plugin-shell/` セクション追記
- [ ] `README.md` (root) Packages 表に `@rescript-tauri/plugin-shell` 行追加
- [ ] `packages/plugin-shell/README.md` の features を埋める
- [ ] `packages/plugin-shell/CHANGELOG.md` の `Unreleased` エントリを記入
- [ ] コミット: `📝 Document @rescript-tauri/plugin-shell`

## Phase 6: 最終検証

- [ ] `pnpm --workspace-concurrency 1 --recursive build` 成功
- [ ] `pnpm --workspace-concurrency 1 --recursive test` 全件 pass
- [ ] tasklist.md の全タスクを `[x]` に更新
- [ ] コミット: `✅ Mark steering 051 tasks complete`

## Phase 7: マージ・クリーンアップ

- [ ] CWD をメインリポジトリに変更
- [ ] 未追跡 `.steering/` ファイルがあれば事前削除
- [ ] `git merge worktree-plugin-shell --no-ff -m "Merge branch 'worktree-plugin-shell'"`
- [ ] worktree 削除
- [ ] ブランチ削除
- [ ] `git worktree list` で main のみ確認
