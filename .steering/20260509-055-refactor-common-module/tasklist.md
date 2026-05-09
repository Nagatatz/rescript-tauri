# Steering 055: Tasklist — Common モジュール抽出

各タスクは単独でコミット可能な粒度で構成。実装 + テスト + ドキュメントを 1 ユニットに収め、各完了時点で `pnpm --recursive build && pnpm --recursive test` が green になることを保つ。

## Phase 1: 計画
- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成
- [x] EnterWorktree で `worktree-refactor-common-module` 作成 (baseRef=head: 直近 main の commit を取り込むため)

## Phase 2: 実装

### Task 1: `Common.res(i)` 新設 + signature テスト
- [x] `packages/core/src/Common.res` 作成 (`unlisten` / `color` / `dragDropEvent` + 内部 `decodeDragDropEvent`)
- [x] `packages/core/src/Common.resi` 作成 (公開 3 型 + Tauri 公式 URL doc comment)
- [x] `packages/core/tests/common_signature.res` 新規作成
- [x] `pnpm --filter @rescript-tauri/core build` 成功確認
- [x] `pnpm --filter @rescript-tauri/core test` 成功確認 (既存 runtime テスト無破壊)
- [x] コミット: `✨ Add Common module for shared types (unlisten / color / dragDropEvent)`

### Task 2: `Window.res(i)` を Common 参照に切り替え
- [x] `Window.res` から `unlisten` / `color` / `dragDropEvent` 型定義を削除し alias 化
- [x] `Window.resi` の同 3 型を `Common.X` 参照に変更
- [x] `Window.res` の workaround コメント (line 283-284) と `Window.resi` の同等コメント (line 805-808) を削除
- [x] `let onDragDropEvent` を `Common.decodeDragDropEvent` 経由に書き換え
- [x] `tests/window_signature.res` を更新 (`Window.color` → `Common.color` 等)
- [x] `pnpm --filter @rescript-tauri/core build && test` 成功確認
- [x] コミット: `♻️ Switch Window to Common.{unlisten, color, dragDropEvent}`

### Task 3: `Webview.res(i)` を Common 参照に切り替え
- [x] `Webview.res` から `unlisten` / `dragDropEvent` 削除し alias 化
- [x] `Webview.resi` の同型を `Common.X` 参照に変更
- [x] `Webview.options.backgroundColor` / `setBackgroundColor` の型を `Common.color` に変更
- [x] `let onDragDropEvent` を `Common.decodeDragDropEvent` 経由に書き換え
- [x] `tests/webview_signature.res` を更新
- [x] `pnpm --filter @rescript-tauri/core build && test` 成功確認
- [x] コミット: `♻️ Drop Webview→Window dependency by routing through Common`

### Task 4: `WebviewWindow.res(i)` の `color` 参照を Common に切り替え
- [x] `WebviewWindow.options.backgroundColor` の型を `Common.color` に変更
- [x] `WebviewWindow.setBackgroundColor` の型を `Common.color` に変更
- [x] `tests/webview_window_signature.res` を更新
- [x] `pnpm --filter @rescript-tauri/core build && test` 成功確認
- [x] コミット: `♻️ Switch WebviewWindow color references to Common.color`

### Task 5: `Event.res(i)` の `unlisten` を Common に切り替え
- [x] `Event.res` の `type unlisten` を `Common.unlisten` 参照に変更
- [x] `Event.resi` の同 (`.resi` には独立定義はなく `unlisten` を export しているのみ。要確認)
- [x] `pnpm --filter @rescript-tauri/core build && test` 成功確認
- [x] コミット: `♻️ Switch Event.unlisten to Common.unlisten`

### Task 6: `Tauri.res(i)` umbrella に Common 追加
- [x] `Tauri.res` に `module Common = Common` 追加
- [x] `Tauri.resi` に `module Common = Common` 追加 (doc comment 付き)
- [x] `tests/tauri_signature.res` に `Common` 経由の参照行追加
- [x] `pnpm --filter @rescript-tauri/core build && test` 成功確認
- [x] コミット: `✨ Re-export Common from Tauri umbrella`

### Task 7: ドキュメント更新
- [x] `docs/repository-structure.md` の core/ ファイル一覧に `Common.res(i)` 追記
- [x] `packages/core/README.md` の module 一覧に Common を追記 (該当箇所があれば)
- [x] `pnpm --recursive build && pnpm --recursive test` で全パッケージ green 確認
- [x] coverage threshold 確認: `pnpm --filter @rescript-tauri/core test:coverage` を実行し閾値に抵触しないこと
- [x] コミット: `📝 Document Common module in repository-structure`

## Phase 3: マージ前

- [x] `.steering/20260509-055-refactor-common-module/tasklist.md` の全タスクを `[x]` に更新
- [x] tasklist 更新を含めた最終コミット
- [x] `git diff origin/main...HEAD --stat` で変更概要を確認

## Phase 4: マージ・クリーンアップ

- [x] AskUserQuestion で main へのマージ可否を確認
- [x] CWD を main repo へ移動
- [x] `git merge worktree-refactor-common-module --no-ff -m ...`
- [x] `git worktree remove .claude/worktrees/refactor-common-module` または `git worktree prune`
- [x] `git branch -d worktree-refactor-common-module`
- [x] クリーンアップ検証: `git worktree list` / `git branch --list 'worktree-*'` / `ls .claude/worktrees/`
