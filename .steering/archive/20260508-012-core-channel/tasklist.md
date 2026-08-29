# タスクリスト: Core.Channel

- [x] **commit 1 (main)**: ステアリング 3 ファイル配置
- [x] EnterWorktree
- [x] **commit 2**: Core.res + Core.resi に Channel モジュール追加（60 modules、warning ゼロ）
- [x] **commit 3**: tests/core_channel_signature.res + tests/runtime/core_channel.test.mjs 3 ケース 新規（transformCallback mock 経由で id 採番 + onMessage delivery + decode failure drop）
- [x] 検証: `pnpm --filter @rescript-tauri/core test` → 4 files, 12 tests passed
- [x] **commit 4**: tasklist 全 [x] 化
- [ ] マージ → クリーンアップ → push
