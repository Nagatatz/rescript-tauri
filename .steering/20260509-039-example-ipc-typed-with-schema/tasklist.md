# Tasklist: examples/ipc-typed-with-schema

> Definition of Done は `.claude/rules/definition-of-done.md` を参照。

## Phase 1: 計画

- [x] worktree (`worktree-example-ipc-typed-with-schema`) 作成 + main 取り込み
- [x] `.steering/20260509-039-example-ipc-typed-with-schema/` 作成
- [x] `requirements.md` 作成
- [x] `design.md` 作成
- [x] `tasklist.md` 作成（本ファイル）

## Phase 2: 実装

### A. ディレクトリ・スキャフォルド

- [x] `examples/ipc-typed-with-schema/` 作成
- [x] `package.json`（design.md §5.1）
- [x] `rescript.json`（design.md §5.2）
- [x] `index.html`（design.md §3.2）

### B. ReScript フロント

- [x] `src/main.mjs`
- [x] `src/App.res`
  - [x] schema 値宣言（greetArgs / addArgs / summarizeArgs / summary）
  - [x] `Schema.fromSchemas` で `greet` / `add` / `summarize` 宣言
  - [x] `Schema.channelFromSchema` で `countChannel` 宣言
  - [x] Channel 引数用の `count_to` を `Core.Command.make` で宣言
  - [x] `Schema.eventFromSchema` 型レベル参照（`appStatusEvent`）
  - [x] `Schema.toDecoder` 参照（`_stringDecoder`）
  - [x] `invokeErrorToString` ヘルパ
  - [x] 4 ボタンハンドラ + DOM wiring

### C. Rust バックエンド

- [x] `src-tauri/Cargo.toml`（design.md §4.1）
- [x] `src-tauri/build.rs`（hello-world 流用）
- [x] `src-tauri/src/main.rs`（design.md §4.2 修正版: 2 引数 `summarize`）
- [x] `src-tauri/tauri.conf.json`（design.md §4.3）
- [x] `src-tauri/capabilities/default.json`（design.md §4.4）
- [x] `src-tauri/icons/` を hello-world からコピー

### D. 検証

- [x] `pnpm install`
- [x] `pnpm --filter ipc-typed-with-schema build`
- [x] `pnpm --recursive build`
- [x] `pnpm --recursive test`

> 単体テスト省略の理由: examples は使用例であり、`packages/schema/`
> 側で signature + runtime テストを既に網羅済み（`testing.md` 例外節）。

### E. ドキュメント

- [x] `examples/ipc-typed-with-schema/README.md`
- [x] `docs/repository-structure.md` §3 の examples リストに追記

## Phase 3: コミット前検証

- [x] tasklist.md の進捗を `[x]` 更新

## Phase 4: コミット

- [x] commit 1: `✨ Add examples/ipc-typed-with-schema`
  - 含む: `examples/ipc-typed-with-schema/**` 全ファイル + ステアリング 3 種 + pnpm-lock 更新
- [x] commit 2: `📝 Register ipc-typed-with-schema in repository-structure`
  - 含む: `docs/repository-structure.md` 更新
- [x] commit 3 (最終): `📝 Mark steering 039 tasks complete pre-merge`

## Phase 5: マージ

- [x] `AskUserQuestion` で main マージ可否確認
- [x] 承認後:
  - [x] CWD を main リポジトリに移動 (ExitWorktree keep)
  - [x] 並行セッション WIP の取り扱い (stash / 切替)
  - [x] `git merge worktree-example-ipc-typed-with-schema --no-ff -m "..."`
  - [x] `git worktree remove .claude/worktrees/example-ipc-typed-with-schema`
  - [x] `git branch -d worktree-example-ipc-typed-with-schema`

## Phase 6: 検証

- [x] `git worktree list` から example-ipc-typed-with-schema が消える
- [x] `git branch --list 'worktree-example-ipc-typed-with-schema'` 空

## Phase 7: 親プラン更新

- [x] `.steering/20260509-030-phase2-planning/tasklist.md` の §D
      schema 実装セクションの `examples/ipc-typed-with-schema/ 追加`
      を `[x]` に更新
