# Steering 057: Tasklist — Common モジュール抽出

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

### Tasks 2-5: 既存モジュールを Common 参照に切り替え (合体コミット)

Window / Webview / WebviewWindow / Event は `Window.color` の cross-reference を介して相互依存していたため、当初予定していた個別コミットには分割できず、4 モジュールを **1 つの合体コミット** として landing した:

- [x] `Window.res(i)`: `unlisten` / `color` / `dragDropEvent` を削除し `Common.X` 参照化、workaround コメント (line 283-284 / 805-808) を削除、`onDragDropEvent` を `Common.decodeDragDropEvent` 経由に書き換え
- [x] `Webview.res(i)`: `unlisten` / `dragDropEvent` 削除、`backgroundColor` 系を `Common.color` 参照化、`onDragDropEvent` を `Common.decodeDragDropEvent` 経由に書き換え (Webview→Window 依存が完全に消えた)
- [x] `WebviewWindow.res(i)`: `backgroundColor` 系を `Common.color` 参照化
- [x] `Event.res(i)`: `unlisten` を `Common.unlisten` 参照化
- [x] `tests/window_signature.res` / `tests/webview_signature.res` / `tests/webview_window_signature.res` / `tests/event_signature.res` 更新
- [x] `pnpm --filter @rescript-tauri/core build && test` 成功確認 (182 tests pass)
- [x] コミット: `♻️ Route Window / Webview / WebviewWindow / Event through Common`

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

- [x] `.steering/20260509-057-refactor-common-module/tasklist.md` の全タスクを `[x]` に更新
- [x] tasklist 更新を含めた最終コミット
- [x] `git diff origin/main...HEAD --stat` で変更概要を確認

## Phase 4: マージ・クリーンアップ

- [x] AskUserQuestion で main へのマージ可否を確認
- [x] CWD を main repo へ移動
- [x] `git merge worktree-refactor-common-module --no-ff -m ...`
- [x] `git worktree remove .claude/worktrees/refactor-common-module` または `git worktree prune`
- [x] `git branch -d worktree-refactor-common-module`
- [x] クリーンアップ検証: `git worktree list` / `git branch --list 'worktree-*'` / `ls .claude/worktrees/`
