# Tasklist: examples/plugin-fs-demo

> Definition of Done は `.claude/rules/definition-of-done.md` を参照。

## Phase 1: 計画

- [x] worktree (`worktree-example-plugin-fs-demo`) 作成 + main 取り込み
- [x] `.steering/20260509-037-example-plugin-fs-demo/` 作成
- [x] `requirements.md` 作成
- [x] `design.md` 作成
- [x] `tasklist.md` 作成（本ファイル）

## Phase 2: 実装

### A. ディレクトリ・スキャフォルド

- [x] `examples/plugin-fs-demo/` 作成
- [x] `package.json` 作成（design.md §5.1）
- [x] `rescript.json` 作成（design.md §5.2）
- [x] `index.html` 作成（design.md §3.2）

### B. ReScript フロント

- [x] `src/main.mjs` 作成
- [x] `src/App.res` 作成
  - [x] 共通定数（demoDir / textFile / bytesFile / copyFile / renamedFile / baseDir）
  - [x] `setResult` ヘルパ
  - [x] `safe` ヘルパ（Promise.catch ラッパ）
  - [x] `runSetup`: mkdir + writeTextFile + writeFile
  - [x] `runRead`: exists + readTextFile + readFile + stat + size
  - [x] `runList`: readDir + lstat
  - [x] `runModify`: copyFile + rename + truncate
  - [x] `runCleanup`: remove (recursive)
  - [x] `bind` ヘルパでクリックハンドラ登録

### C. Rust バックエンド

- [x] `src-tauri/Cargo.toml` 作成（design.md §4.1）
- [x] `src-tauri/build.rs` 作成（hello-world 流用）
- [x] `src-tauri/src/main.rs` 作成（design.md §4.2）
- [x] `src-tauri/tauri.conf.json` 作成（design.md §4.3）
- [x] `src-tauri/capabilities/default.json` 作成（design.md §4.4）
- [x] `src-tauri/icons/` を hello-world からコピー

### D. 検証

- [x] `pnpm install` でワークスペースに plugin-fs-demo が認識される
- [x] `pnpm --filter plugin-fs-demo build` 成功
- [x] `pnpm --recursive build` で他パッケージに regression なし
- [x] `pnpm --recursive test` 全件パス

> 単体テスト省略の理由: examples は使用例であり、対応する
> ライブラリ側 (`packages/plugin-fs/`) で signature + runtime
> テストを既に網羅済み（`testing.md` 例外節適用）。

### E. ドキュメント

- [x] `examples/plugin-fs-demo/README.md` 作成
- [x] `docs/repository-structure.md` §3 の examples リストに追記

## Phase 3: コミット前検証

- [x] tasklist.md の進捗を `[x]` 更新

## Phase 4: コミット

- [ ] commit 1: `✨ Add examples/plugin-fs-demo`
  - 含む: `examples/plugin-fs-demo/**` 全ファイル + ステアリング 3 種 + pnpm-lock 更新
- [ ] commit 2: `📝 Register plugin-fs-demo in repository-structure`
  - 含む: `docs/repository-structure.md` 更新
- [ ] commit 3 (最終): `📝 Mark steering 037 tasks complete pre-merge`
  - 含む: `tasklist.md` 全 [x] 化

## Phase 5: マージ

- [ ] `AskUserQuestion` で main マージ可否確認
- [ ] 承認後:
  - [ ] CWD を main リポジトリに移動 (ExitWorktree keep)
  - [ ] 並行セッション WIP の取り扱い確認（前 steering で発覚した
        chore/bump-happy-dom-security 状況に応じて）
  - [ ] `git merge worktree-example-plugin-fs-demo --no-ff -m "..."`
  - [ ] `git worktree remove .claude/worktrees/example-plugin-fs-demo`
  - [ ] `git branch -d worktree-example-plugin-fs-demo`

## Phase 6: 検証

- [ ] `git worktree list` から example-plugin-fs-demo が消えている
- [ ] `git branch --list 'worktree-example-plugin-fs-demo'` 空

## Phase 7: 親プラン更新

- [ ] `.steering/20260509-030-phase2-planning/tasklist.md` の
      "E. plugin-fs 実装" セクションの
      `examples/plugin-fs-demo/ 追加` を `[x]` に更新
