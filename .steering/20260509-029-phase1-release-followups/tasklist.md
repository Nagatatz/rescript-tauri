# Tasklist: Phase 1 リリース後フォローアップ

- [x] `.steering/20260509-029-phase1-release-followups/` ディレクトリ作成
- [x] requirements.md / design.md / tasklist.md 作成
- [x] worktree `worktree-phase1-release-followups` 作成（main を base にリベース済）
- [x] `tests/runtime/core_raw.test.mjs` を `Mocks.mockIPC` ベースに書き換え
- [x] `tests/runtime/core_command.test.mjs` を `Mocks.mockIPC` ベースに書き換え
- [x] `release-checklist.md` を steering ディレクトリに配置
- [x] `pnpm --filter @rescript-tauri/core test` 緑（26/26）
- [x] コミット (`✅ Refactor core_raw / core_command tests to use Mocks.mockIPC + add Phase 1 release checklist`)
- [x] tasklist.md の全タスク `[x]` 化と最終コミット
- [x] main へマージ
- [x] worktree とブランチを削除
