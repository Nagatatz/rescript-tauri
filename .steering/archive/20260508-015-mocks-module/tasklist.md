# タスクリスト: Mocks モジュール

- [x] **commit 1 (main)**: ステアリング 3 ファイル配置
- [x] EnterWorktree
- [x] **commit 2**: Mocks.res + Mocks.resi 新規 (66 modules、warning ゼロ)
- [x] **commit 3**: tests/mocks_signature.res + tests/runtime/mocks.test.mjs 4 ケース 新規（mockIPC で Raw.invoke 経由 / Command.invoke round-trip / clearMocks / mockWindows API smoke test）
- [x] 検証: `pnpm --filter @rescript-tauri/core test` → 7 files, 25 tests passed
- [x] **commit 4**: tasklist 全 [x] 化
- [ ] マージ → クリーンアップ → push
