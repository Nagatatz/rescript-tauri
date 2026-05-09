# タスクリスト: `@rescript-tauri/plugin-shell` 新規パッケージ

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-051-plugin-shell` |
| ブランチ | `worktree-plugin-shell`（worktree 経由） |

## Phase 0: 準備

- [x] worktree を作成 (`EnterWorktree plugin-shell`)
- [x] requirements.md / design.md / tasklist.md をユーザー承認

## Phase 1: パッケージ scaffolding

- [x] `packages/plugin-shell/package.json`
- [x] `packages/plugin-shell/rescript.json`
- [x] `packages/plugin-shell/vitest.config.mjs`
- [x] `packages/plugin-shell/README.md`
- [x] `packages/plugin-shell/CHANGELOG.md`
- [x] `pnpm install` で workspace に取り込み・peerDependency を解決
- [x] コミット: `🔧 Scaffold @rescript-tauri/plugin-shell package`

## Phase 2: バインディング実装

- [x] `src/PluginShell.res` / `.resi`
  - [x] 型: `spawnOptions` / `childProcess<'o>` / `terminatedPayload`
  - [x] `openPath` 関数
  - [x] `Command` モジュール（`create` / `createRaw` / `sidecar` / `sidecarRaw` / `spawn` / `execute` / `onClose` / `onError` / `onStdoutData` / `onStderrData` / `removeAllListeners` / `stdout` / `stderr`）
  - [x] `Child` モジュール（`pid` / `write` / `kill`）
  - [x] `EventEmitter` モジュール（9 method）
- [x] `pnpm --filter @rescript-tauri/plugin-shell build` 成功
- [x] コミット: `✨ Implement @rescript-tauri/plugin-shell bindings`

## Phase 3: テスト

- [x] `tests/plugin_shell_signature.res` — 全公開シンボルへの型注釈付き呼び出し
- [x] `tests/runtime/plugin_shell.test.mjs` — `Mocks.mockIPC` で IPC コマンド名検証
- [x] `pnpm --filter @rescript-tauri/plugin-shell test` 全件 pass
- [x] コミット: `✅ Add type-level and runtime tests for plugin-shell`

## Phase 4: CI 拡張

- [x] `.github/workflows/tests-plugin-shell-types.yml` 新設
- [x] `.github/workflows/tests-plugin-shell-runtime.yml` 新設
- [x] `.github/workflows/tests-coverage.yml` matrix に `plugin-shell` 追加
- [x] コミット: `🔧 Add plugin-shell CI workflows and coverage matrix entry`

## Phase 5: ドキュメント更新

- [x] `docs/repository-structure.md` §2.2 に `plugin-shell/` セクション追記
- [x] `README.md` (root) Packages 表に `@rescript-tauri/plugin-shell` 行追加
- [x] `packages/plugin-shell/README.md` の features を埋める
- [x] `packages/plugin-shell/CHANGELOG.md` の `Unreleased` エントリを記入
- [x] コミット: `📝 Document @rescript-tauri/plugin-shell`

## Phase 6: 最終検証

- [x] `pnpm --workspace-concurrency 1 --recursive build` 成功
- [x] `pnpm --workspace-concurrency 1 --recursive test` 全件 pass
- [x] tasklist.md の全タスクを `[x]` に更新
- [x] コミット: `✅ Mark steering 051 tasks complete`

## Phase 7: マージ・クリーンアップ

- [x] CWD をメインリポジトリに変更
- [x] 未追跡 `.steering/` ファイルがあれば事前削除
- [x] `git merge worktree-plugin-shell --no-ff -m "Merge branch 'worktree-plugin-shell'"`
- [x] worktree 削除
- [x] ブランチ削除
- [x] `git worktree list` で main のみ確認
