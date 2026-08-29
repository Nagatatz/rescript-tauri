# タスクリスト: Window モジュール

- [x] **commit 1 (main)**: ステアリング 3 ファイル配置
- [x] EnterWorktree
- [x] **commit 2**: Window.res + Window.resi 新規 ~20 メソッド（64 modules、warning ゼロ）
- [x] **commit 3**: tests/window_signature.res + tests/runtime/window.test.mjs 5 ケース 新規（実装中の発見: Tauri の `label` は property なので `@send` → `@get` に修正、getByLabel mock の invoke は配列を返す必要）
- [x] 検証: `pnpm --filter @rescript-tauri/core test` → 6 files, 21 tests passed
- [x] **commit 4**: tasklist 全 [x] 化
- [ ] マージ → クリーンアップ → push
