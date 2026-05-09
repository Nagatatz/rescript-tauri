# タスクリスト: `@rescript-tauri/plugin-log`

## Phase 1: scaffold
- [x] package.json / rescript.json / vitest.config.mjs
- [x] README.md / CHANGELOG.md
- [x] pnpm install
- [x] commit

## Phase 2: 実装
- [x] PluginLog.res / .resi（5 log fn + attachLogger + attachConsole + LogLevel module + types）
- [x] build 通る
- [x] commit

## Phase 3: テスト
- [x] plugin_log_signature.res
- [x] runtime/plugin_log.test.mjs
- [x] test 通る
- [x] commit

## Phase 4: CI
- [x] tests-plugin-log-{types,runtime}.yml
- [x] tests-coverage.yml matrix
- [x] release.yml tag prefix
- [x] commit

## Phase 5: ドキュメント
- [x] root README + repository-structure.md
- [x] commit

## Phase 6: 検証 + マージ
- [x] monorepo build + test 全件 pass
- [x] tasklist [x] 化
- [x] main にマージ
- [x] worktree / branch 削除
