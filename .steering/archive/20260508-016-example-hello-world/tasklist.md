# タスクリスト: examples/hello-world

- [x] **commit 1 (main)**: ステアリング 3 ファイル配置
- [x] EnterWorktree
- [x] **commit 2**: examples/hello-world/ 配下に frontend (package.json, rescript.json, src/App.res, src/main.mjs, index.html) + Rust scaffolding (Cargo.toml, build.rs, src/main.rs, tauri.conf.json) + README
- [x] 検証: `pnpm install && pnpm --filter hello-world build` → 62 modules compiled, zero warnings、`src/App.res.mjs` 生成
- [x] **commit 3**: tasklist 全 [x] 化
- [ ] マージ → クリーンアップ → push
