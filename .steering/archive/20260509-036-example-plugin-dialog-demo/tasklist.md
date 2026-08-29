# Tasklist: examples/plugin-dialog-demo

> Definition of Done は `.claude/rules/definition-of-done.md` を参照。
> 各タスク着手時に即座に `[x]` 化する。

## Phase 1: 計画

- [x] `.steering/20260509-036-example-plugin-dialog-demo/` 作成
- [x] `requirements.md` 作成
- [x] `design.md` 作成
- [x] `tasklist.md` 作成（本ファイル）
- [x] ユーザー承認取得
- [x] `EnterWorktree` で worktree 作成

## Phase 2: 実装

### A. ディレクトリ・スキャフォルド

- [x] `examples/plugin-dialog-demo/` 作成
- [x] `package.json` 作成（design.md §5.1）
- [x] `rescript.json` 作成（design.md §5.2）
- [x] `index.html` 作成（design.md §3.2）
- [x] `pnpm-workspace.yaml` を確認し必要なら追記（既存 `examples/*` で網羅、追加不要）

### B. ReScript フロント

- [x] `src/main.mjs` 作成
- [x] `src/App.res` 作成
  - [x] `<pre id="result">` への結果書き込みヘルパ
  - [x] `openFile` ボタン handler
  - [x] `openFiles` ボタン handler
  - [x] `openDirectory` ボタン handler
  - [x] `openDirectories` ボタン handler
  - [x] `save` ボタン handler
  - [x] `message` (info) ボタン handler
  - [x] `message` (error) ボタン handler
  - [x] `ask` ボタン handler
  - [x] `confirm` ボタン handler
  - [x] `pickerMode` / `fileAccessMode` 型参照ダミー
  - [x] `Promise.catch` で各 handler を保護

### C. Rust バックエンド

- [x] `src-tauri/Cargo.toml` 作成（design.md §4.1）
- [x] `src-tauri/build.rs` 作成（hello-world 流用）
- [x] `src-tauri/src/main.rs` 作成（design.md §4.2）
- [x] `src-tauri/tauri.conf.json` 作成（design.md §4.3）
- [x] `src-tauri/capabilities/default.json` 作成（design.md §4.4）
- [x] `src-tauri/icons/` を hello-world からコピー

### D. テスト

- [x] `pnpm --filter plugin-dialog-demo build` ローカル実行で成功
- [x] `pnpm --recursive build` で regression なし
- [x] `pnpm --recursive test` で他パッケージのテストが全件パス

> 注: examples 自体は CI 上で OS 3 種マトリクスのビルドが本テストと
> なる。本 steering ではローカルの ReScript ビルドが通ることまでで
> 完了とする（受け入れ条件 §2 と整合）。
> 単体テスト省略の理由: examples は使用例であり、対応する
> ライブラリ側 (`packages/plugin-dialog/`) で signature + runtime
> テストを既に網羅済み（`testing.md` 例外節適用）。

### E. ドキュメント

- [x] `examples/plugin-dialog-demo/README.md` 作成
- [x] `docs/repository-structure.md` §3 の examples リストに追記

## Phase 3: コミット前検証

- [x] ビルド成功確認 (`pnpm --recursive build`)
- [x] テスト成功確認 (`pnpm --recursive test`)
- [x] tasklist.md の進捗を `[x]` 更新

## Phase 4: コミット

コミット粒度（git-conventions.md §コミット粒度）:

- [x] commit 1: `✨ Add examples/plugin-dialog-demo`
  - 含む: `examples/plugin-dialog-demo/**` 全ファイル + ステアリング 3 種 + pnpm-lock 更新
- [x] commit 2: `📝 Register plugin-dialog-demo in repository-structure`
  - 含む: `docs/repository-structure.md` 更新
- [x] commit 3 (最終): `📝 Mark steering 036 tasks complete pre-merge`
  - 含む: `.steering/20260509-036-.../tasklist.md` 全 [x] 化

> ステアリングファイル単独コミットを避けるため、commit 1 に同梱した。
> commit 2 は docs 単発の小変更のため独立化。

## Phase 5: マージ

- [x] `AskUserQuestion` で main マージ可否確認
- [x] 承認後:
  - [x] CWD を main リポジトリに移動
  - [x] 未追跡ステアリングファイル競合の事前解消
  - [x] `git merge worktree-example-plugin-dialog-demo --no-ff -m "Merge branch ..."`
  - [x] `git worktree remove .claude/worktrees/example-plugin-dialog-demo`
  - [x] `git branch -d worktree-example-plugin-dialog-demo`

## Phase 6: 検証

- [x] `git worktree list` で main のみ
- [x] `git branch --list 'worktree-*'` 空
- [x] `.claude/worktrees/` 空

## Phase 7: 親プラン更新

- [x] `.steering/20260509-030-phase2-planning/tasklist.md` の
      "F. plugin-dialog 実装" セクションの
      `examples/plugin-dialog-demo/ 追加` を `[x]` に更新
      （※ 親 tasklist の該当行を要確認、無ければ追記）
