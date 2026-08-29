# タスクリスト: Event モジュール

- [x] **commit 1 (main)**: ステアリング 3 ファイル配置
- [x] EnterWorktree
- [x] **commit 2**: Event.res + Event.resi 新規（abstract t<'payload> と concrete record の食い違い解消のため `let make: (...): t<'payload> => ...` 等の型 annotation を追加、ドット partial application は明示 lambda に変更）
- [x] **commit 3**: tests/event_signature.res + tests/runtime/event.test.mjs 4 ケース 新規（transformCallback mock + invoke vi.fn で listen / emit / emitTo / decode failure drop を検証）
- [x] 検証: `pnpm --filter @rescript-tauri/core test` → 5 files, 16 tests passed
- [x] **commit 4**: tasklist 全 [x] 化
- [ ] マージ → クリーンアップ → push
