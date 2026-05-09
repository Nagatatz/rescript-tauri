# Tasklist: Package READMEs (Phase 2 互換マトリクス整備)

> Definition of Done は `.claude/rules/definition-of-done.md` を参照。

## Phase 1: 計画

- [x] worktree (`worktree-phase2-readme-matrices`) 作成 + main 取り込み
- [x] `.steering/20260509-043-package-readmes/` 作成
- [x] `requirements.md`
- [x] `design.md`
- [x] `tasklist.md`（本ファイル）

## Phase 2: 実装

### A. `packages/core/README.md` リフレッシュ

- [x] Status を Phase 1 完了 + publish pending に
- [x] Quick example を Phase 1 機能を反映する形に
- [x] Compatibility matrix 追加 (5 行版: core / @tauri-apps/api /
      rescript / @rescript/core / OS)
- [x] Public API モジュール表 (12 モジュール)
- [x] See also 節 (sphinx-docs + examples 4 件)
- [x] Development 節は維持

### B. `packages/schema/README.md` 更新

- [x] Status を実装完了 + publish pending に
- [x] Quick example の `s->S.field` を `s.field` に修正
- [x] Compatibility matrix を 7 行版に拡張 (rescript-struct
      非対応の注記つき)
- [x] References 節を See also に整理
  - sphinx-docs `user/schema.md`
  - `examples/ipc-typed-with-schema/`

### C. `packages/plugin-fs/README.md` 更新

- [x] Compatibility matrix を 8 行版に拡張 (Rust crate 行 + toolchain)
- [x] 落とし穴節 (single-field punning + TypedArray.length)
- [x] See also 節:
  - sphinx-docs `user/plugin-fs.md`
  - `examples/plugin-fs-demo/`
  - 上流 plugin docs

### D. `packages/plugin-dialog/README.md` 更新

- [x] "Deferred to follow-up sub-steerings" を最新化:
  - example app → 完了済 (steering 036)
  - CI job → 完了済 (steering 041)
  - release.yml plugin-dialog-v* タグ → 完了済 (steering 041)
  - 残るは MessageDialogButtonsYesNoCustom 等カスタムボタンラベル
- [x] Compatibility matrix を 8 行版に拡張
- [x] See also 節:
  - sphinx-docs `user/plugin-dialog.md`
  - `examples/plugin-dialog-demo/`
  - 上流 plugin docs

### E. 検証

- [x] 4 README を text-check (タブ・heading・リンク URL)
- [x] 互換マトリクスの値が package.json の peerDependencies と一致
- [x] `pnpm --recursive build` regression なし
- [x] `pnpm --recursive test` 全件パス (47 tests)

## Phase 3: コミット前検証

- [x] tasklist.md の進捗を `[x]` 更新

## Phase 4: コミット

- [x] commit 1: `📝 Refresh @rescript-tauri/core README for Phase 1 release`
  - 含む: `packages/core/README.md`
- [x] commit 2: `📝 Augment Phase 2 package READMEs with toolchain rows + cross-links`
  - 含む: schema / plugin-fs / plugin-dialog README
- [x] commit 3 (最終): `📝 Mark steering 043 tasks complete pre-merge`
  - 含む: ステアリング 3 ファイル + tasklist 全 [x]

## Phase 5: マージ

- [x] `AskUserQuestion` で main マージ可否確認
- [x] 承認後:
  - [x] CWD を main リポジトリに移動 (ExitWorktree keep)
  - [x] `git merge worktree-phase2-readme-matrices --no-ff -m "..."`
  - [x] `git worktree remove .claude/worktrees/phase2-readme-matrices`
  - [x] `git branch -d worktree-phase2-readme-matrices`

## Phase 6: 検証

- [x] `git worktree list` から phase2-readme-matrices が消える
- [x] `git branch --list 'worktree-phase2-readme-matrices'` 空

## Phase 7: 親プラン更新

- [x] `.steering/20260509-030-phase2-planning/tasklist.md` の §I
      `各パッケージの README に互換マトリクス記載` を `[x]` に更新
