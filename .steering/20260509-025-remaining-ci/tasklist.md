# Tasklist: 残り CI workflows

- [x] `.steering/20260509-025-remaining-ci/` ディレクトリ作成
- [x] requirements.md / design.md / tasklist.md 作成
- [x] worktree `worktree-phase1-remaining-ci` 作成（main を base にリベース済）
- [x] `.github/workflows/compat-tauri-latest.yml` 作成
- [x] `.github/workflows/compat-rescript-prerelease.yml` 作成
- [x] `.github/workflows/release.yml` 作成
- [x] `.github/workflows/README.md` を更新（Active テーブルに 3 行、Planned セクション削除）
- [x] `actionlint` で全 workflow が緑であることを確認
- [x] `pnpm --filter @rescript-tauri/core build` が引き続き緑
- [x] コミット (`🔧 Add compat-tauri-latest / compat-rescript-prerelease / release CI workflows`)
- [x] tasklist.md の全タスク `[x]` 化と最終コミット
- [x] main へマージ
- [x] worktree とブランチを削除
