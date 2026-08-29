# Tasklist: Window 全 API 展開

- [x] `.steering/20260509-018-window-full-api/` ディレクトリ作成
- [x] requirements.md / design.md / tasklist.md 作成
- [x] worktree `worktree-phase1-window-expansion` 作成
- [x] `Window.resi` に新規型 (theme, cursorIcon, userAttentionType, resizeDirection, titleBarStyle, progressBarState, windowSizeConstraints, closeRequestedEvent, scaleFactorChanged, monitor, color, effects, effectStyle, effectState) を追加
- [x] `Window.resi` にスタティック関数 (getFocusedWindow, currentMonitor, primaryMonitor, monitorFromPoint, availableMonitors, cursorPosition) を追加
- [x] `Window.resi` にインスタンスメソッド (isFullscreen, isDecorated, isResizable, ...) を追加
- [x] `Window.resi` に `on*` ハンドラを追加（`Window.unlisten` 型を併設）
- [x] `Window.res` に対応する `external` を追加
- [x] `tests/window_signature.res` を全公開シンボル網羅に拡張
- [x] `pnpm --filter @rescript-tauri/core build` 成功を確認
- [x] `pnpm --filter @rescript-tauri/core test` 全件パスを確認
- [x] doc-link-lint 用に各 `.resi` シンボルに Tauri URL を入れた
- [x] コミット (`✨ Expand Window module to cover full Tauri Window class`)
- [x] tasklist.md の全タスク `[x]` 化と最終コミット
- [x] main へのマージ可否確認 → main へマージ
- [x] worktree とブランチを削除
