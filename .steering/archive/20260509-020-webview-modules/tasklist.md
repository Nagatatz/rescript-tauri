# Tasklist: Webview / WebviewWindow モジュール

- [x] `.steering/20260509-020-webview-modules/` ディレクトリ作成
- [x] requirements.md / design.md / tasklist.md 作成
- [x] worktree `worktree-phase1-webview-modules` 作成（main を base にリベース済）
- [x] `Webview.res` / `Webview.resi` 作成（opaque + getCurrentWebview / getAllWebviews / インスタンス API + onDragDropEvent ラッパ）
- [x] `WebviewWindow.res` / `WebviewWindow.resi` 作成（opaque + asWindow/asWebview %identity + 頻用 @send 再エクスポート）
- [x] `tests/webview_signature.res` 作成
- [x] `tests/webview_window_signature.res` 作成
- [x] `pnpm --filter @rescript-tauri/core build` 緑
- [x] `pnpm --filter @rescript-tauri/core test` 緑（25/25）
- [x] 公開シンボルカバレッジ緑 (225/219)
- [x] コミット (`✨ Add Webview / WebviewWindow modules`)
- [x] tasklist.md の全タスク `[x]` 化と最終コミット
- [x] main へマージ
- [x] worktree とブランチを削除
