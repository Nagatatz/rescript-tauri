# Tasklist: examples/plugin-http-demo

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-009 |
| 関連 | requirements.md / design.md |

## Phase 1: 計画

- [x] requirements.md 作成
- [x] design.md 作成
- [x] tasklist.md 作成
- [x] ユーザー承認
- [x] steering 3 点セットを main 上で commit (`815ad33 📝 Add steering 20260511-009 plan: example plugin-http-demo`)
- [x] EnterWorktree plugin-http-demo + ローカル main を sync merge

## Phase 2: 実装

各 checkpoint 単独 commit。

### Checkpoint 1: Rust 側 + 設定スケルトン

- [x] `examples/plugin-http-demo/src-tauri/Cargo.toml` 作成（`tauri = "2"` + `tauri-plugin-http = "2"`）
- [x] `examples/plugin-http-demo/src-tauri/build.rs` 作成
- [x] `examples/plugin-http-demo/src-tauri/src/main.rs` 作成（`tauri_plugin_http::init()` 登録）
- [x] `examples/plugin-http-demo/src-tauri/tauri.conf.json` 作成
- [x] `examples/plugin-http-demo/src-tauri/capabilities/default.json` 作成（`http:default` + scoped allow）
- [x] `examples/plugin-http-demo/src-tauri/icons/` を plugin-fs-demo から流用（PNG / ICO / ICNS）
- [x] ルート `Cargo.toml` の `workspace.members` に `examples/plugin-http-demo/src-tauri` 追加
- [x] commit: `🔧 Scaffold plugin-http-demo Rust side (Cargo + capabilities + config)`

### Checkpoint 2: Frontend スケルトン + Step 1 GET

- [x] `examples/plugin-http-demo/package.json` 作成（workspace `:*` deps）
- [x] `examples/plugin-http-demo/rescript.json` 作成
- [x] `examples/plugin-http-demo/index.html` 作成（ボタン × 4 + result pre）
- [x] `examples/plugin-http-demo/src/main.mjs` 作成
- [x] `examples/plugin-http-demo/src/App.res` 作成（`runGet` step 1 のみ実装、`safe`/`setResult` ヘルパ込み）
- [x] `pnpm install` で workspace に取り込む
- [x] `pnpm --filter plugin-http-demo build` 成功確認
- [x] commit: `✨ Add plugin-http-demo frontend with Step 1 (GET)`

### Checkpoint 3: Step 2-4 (POST / clientOptions / headers)

- [x] `runPost` 実装（jsonplaceholder/posts へ POST）
- [x] `runClientOptions` 実装（connectTimeout + maxRedirections）
- [x] `runHeaders` 実装（status + headers.get + text()）
- [x] `main()` で 4 button をすべて wire
- [x] `pnpm --filter plugin-http-demo build` 成功確認 (`JSON.Encode.*` / `Math.Int` 不在問題を修正)
- [x] commit: `✨ Implement plugin-http-demo steps 2-4 (POST / clientOptions / headers)`

### Checkpoint 4: README + CI + ドキュメント整合

- [ ] `examples/plugin-http-demo/README.md` 作成（plugin-fs-demo スタイル）
- [ ] `.github/workflows/examples-build.yml` に `plugin-http-demo` build + `cargo check` ステップ追加（plugin-fs-demo ブロックの直後に挿入）
- [ ] `docs/repository-structure.md` の `examples/` ツリーに `plugin-http-demo/` 追加
- [ ] `sphinx-docs/user/plugin-http.md` の See also に live demo リンク追加
- [ ] `packages/plugin-http/CHANGELOG.md` の Unreleased セクションに「examples/plugin-http-demo added (steering 009)」追記
- [ ] commit: `📝 Wire plugin-http-demo into CI / docs / changelog`

## Phase 3: マージ前検証

- [ ] `pnpm --filter plugin-http-demo build` 最終確認
- [ ] `cd examples/plugin-http-demo/src-tauri && cargo check --release` 成功
- [ ] `grep -rn "plugin-http-demo" docs/ sphinx-docs/ .github/ Cargo.toml` で intended 箇所すべて反映
- [ ] tasklist.md の全タスク `[x]` 化
- [ ] commit: `✅ Mark steering 20260511-009 tasklist complete`

## Phase 4: マージ

- [ ] `AskUserQuestion` で main へのマージ可否確認
- [ ] CWD を main へ移動 (ExitWorktree action=keep)
- [ ] 並列セッションの main 更新を取り込む（`git merge origin/main` を念のため、ローカル main に対しては不要なら省略）
- [ ] `git merge worktree-plugin-http-demo --no-ff -m "Merge branch 'worktree-plugin-http-demo' (steering 20260511-009: examples/plugin-http-demo)"`
- [ ] worktree remove: `git worktree remove .claude/worktrees/plugin-http-demo`
- [ ] branch delete: `git branch -d worktree-plugin-http-demo`
- [ ] 検証:
  - `git worktree list` で main + 他並列 worktree のみ
  - `git branch --list 'worktree-*'` に worktree-plugin-http-demo がない
  - `.claude/worktrees/plugin-http-demo/` 不在

## ロールバック条件

- jsonplaceholder URL に CI 環境から到達できない場合 → README に「ネットワーク必須」を明記しつつ、デモ自体は build/cargo check 通過なら成立
- cargo check 失敗 → `tauri-plugin-http` バージョン固定や features 確認
- 並列セッションが `examples-build.yml` を大幅変更した場合 → 手動 conflict resolution
