# タスクリスト: Core.Raw.convertFileSrc

- [x] **commit 1 (main)**: ステアリング 3 ファイル配置
- [x] EnterWorktree
- [x] **commit 2**: Core.res + Core.resi に convertFileSrc 追加（Compiled 59 modules）
- [x] **commit 3**: tests/core_raw_signature.res 拡張 + tests/runtime/core_raw_convert.test.mjs 新規（mock を `window.__TAURI_INTERNALS__.convertFileSrc` に install して default protocol "asset" + 明示 protocol の 2 ケース検証）
- [x] 検証: `pnpm --filter @rescript-tauri/core test` → 2 files, 4 tests passed
- [x] **commit 4**: tasklist 全 [x] 化
- [ ] マージ確認 → main マージ → worktree クリーンアップ → push
