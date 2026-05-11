# Tasklist: examples/plugin-shell-demo

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-006 |
| 関連 | `requirements.md`, `design.md` |

各タスクは単独で `git commit` 可能な粒度に分割。

---

## Phase 0: 準備

- [x] T0.1 `git fetch origin` で main 鮮度確認、`EnterWorktree plugin-shell-demo` で worktree 隔離
- [x] T0.2 worktree HEAD が origin/main (fresh) を指していたため、`git merge main` で未 push のローカル main commit (steering 001 / 003 / 004 / 005) を取り込み

## Phase 1: scaffolding (新規ファイル群)

- [x] T1.1 `examples/plugin-shell-demo/package.json` 作成
- [x] T1.2 `examples/plugin-shell-demo/rescript.json` 作成
- [x] T1.3 `examples/plugin-shell-demo/index.html` 作成
- [x] T1.4 `examples/plugin-shell-demo/src/main.mjs` 作成
- [x] T1.5 `examples/plugin-shell-demo/README.md` 作成
- [x] T1.6 `examples/plugin-shell-demo/src/App.res` 作成（design §3.5 + 低レベル EventEmitter reachability 追記）
- [x] T1.7 `examples/plugin-shell-demo/src-tauri/Cargo.toml` 作成
- [x] T1.8 `examples/plugin-shell-demo/src-tauri/build.rs` 作成
- [x] T1.9 `examples/plugin-shell-demo/src-tauri/src/main.rs` 作成
- [x] T1.10 `examples/plugin-shell-demo/src-tauri/capabilities/default.json` 作成
- [x] T1.11 `examples/plugin-shell-demo/src-tauri/tauri.conf.json` 作成（dialog-demo 踏襲: `$schema` は upstream URL、icon は 3 ファイル形式）
- [x] T1.12 `examples/plugin-shell-demo/src-tauri/icons/` を `plugin-dialog-demo` から copy (icon.png / icon.ico / icon.icns)
- [x] T1.13 ローカル検証: `pnpm install` 成功、`pnpm --filter plugin-shell-demo build` で 73 modules compiled。`cargo check` は Phase 2 で workspace 登録後に実行
- [x] T1.14 **コミット**: `✨ Add examples/plugin-shell-demo (steering 20260511-006)` (71c55cd)

## Phase 2: root Cargo workspace 登録

- [x] T2.1 `Cargo.toml` (root) の `members` に `examples/plugin-shell-demo/src-tauri` を追加（plugin-fs-demo の隣、アルファベット順）
- [x] T2.2 ローカル `cargo` 不在のため `cargo check --workspace` はスキップ。全 member パスが実在することを `ls` で確認 (8 ファイル green)。CI `examples-build.yml` が Linux/macOS/Windows 3 OS で実 build を実行
- [ ] T2.3 **コミット**: `🔧 Register plugin-shell-demo in root Cargo workspace`

## Phase 3: ドキュメント更新

- [x] T3.1 `docs/repository-structure.md` の examples 一覧（§1 ルートレイアウト + §3 一覧）両方に `plugin-shell-demo/` 行を追加
- [x] T3.2 `sphinx-docs/user/plugin-shell.md` の "See also" 先頭に live demo リンクを追加
- [ ] T3.3 **コミット**: `📝 Link plugin-shell-demo from docs and user guide`

## Phase 4: 検証

- [ ] T4.1 `git diff main..HEAD --name-only` で差分が `examples/plugin-shell-demo/**`, `Cargo.toml`, `docs/repository-structure.md`, `sphinx-docs/user/plugin-shell.md`, `.steering/20260511-006-.../*.md` に限定されていることを確認
- [ ] T4.2 `pnpm run check`（Biome — `.json` / `.mjs` 対象）が green
- [ ] T4.3 `pnpm --filter plugin-shell-demo build` 再実行で green
- [ ] T4.4 `cargo check --workspace` 再実行で green

## Phase 5: マージ

- [ ] T5.1 tasklist.md Phase 0〜4 を `[x]` に更新
- [ ] T5.2 **コミット**: `📝 Mark steering 20260511-006 tasklist complete`
- [ ] T5.3 `AskUserQuestion` でユーザーに main へのマージ可否を確認
- [ ] T5.4 承認後、main 側の未追跡 `.steering/20260511-006-example-plugin-shell-demo/` を削除（worktree 作成前に main 側に作った残骸があれば）
- [ ] T5.5 `cd <main-repo>` → `git merge worktree-plugin-shell-demo --no-ff` → `git worktree remove .claude/worktrees/plugin-shell-demo` → `git branch -d worktree-plugin-shell-demo`
- [ ] T5.6 クリーンアップ検証: `git worktree list` で main + 他並列セッションのみ表示 / `worktree-plugin-shell-demo` ブランチ削除 / `.claude/worktrees/plugin-shell-demo` 不在

## 後続作業 (out-of-scope)

- 実 sidecar binary をバンドルしたデモ拡張
- E2E テスト（既存 demo にも未整備）
- ja 翻訳（demo は翻訳対象外）
