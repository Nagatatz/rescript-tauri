# Tasklist: Tauri.res 上位 re-export

- [x] `.steering/20260509-023-tauri-reexport/` ディレクトリ作成
- [x] requirements.md / design.md / tasklist.md 作成
- [x] worktree `worktree-phase1-tauri-reexport` 作成（main を base にリベース済）
- [x] `Tauri.res` / `Tauri.resi` 作成（Core / Event / Window / Webview / WebviewWindow の 5 module alias）
- [x] `tests/tauri_signature.res` 作成
- [x] `docs/product-requirements.md` §10 #1 を「確定済み」に更新
- [x] `pnpm --filter @rescript-tauri/core build` 緑
- [x] `pnpm --filter @rescript-tauri/core test` 緑（25/25）
- [x] 公開シンボルカバレッジ緑 (290/310)
- [x] コミット (`✨ Add Tauri.res top-level re-export and confirm PRD §10 #1`)
- [x] tasklist.md の全タスク `[x]` 化と最終コミット
- [x] main へマージ
- [x] worktree とブランチを削除
