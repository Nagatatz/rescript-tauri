# Tasklist: @rescript-tauri/plugin-dialog パッケージ実装

| 項目 | 内容 |
|---|---|
| 関連 | [requirements.md](./requirements.md), [design.md](./design.md) |

## Phase 1: 計画（コード着手前）

- [x] `.steering/20260509-035-plugin-dialog/` 作成
- [x] `requirements.md` 作成（ユーザー承認済み）
- [x] `design.md` 作成（事後ドキュメント化、PCクラッシュ復旧）
- [x] `tasklist.md` 作成（事後ドキュメント化）
- [x] `EnterWorktree` で `worktree-phase2-plugin-dialog` 作成

## Phase 2: 実装

### Step A — パッケージ bootstrap

- [x] `packages/plugin-dialog/package.json`（@rescript-tauri/plugin-dialog, peerDeps）
- [x] `packages/plugin-dialog/rescript.json`
- [x] `packages/plugin-dialog/vitest.config.mjs`
- [x] `packages/plugin-dialog/README.md`

### Step B — 公開 API

- [x] `src/PluginDialog.resi` — 型定義（7 種）+ 関数シグネチャ（8 つ）+ doc comment
- [x] `src/PluginDialog.res` — `_open` external + `_toJsOpen` ヘルパ + 4 open 系関数
- [x] `src/PluginDialog.res` — `save` / `message` / `ask` / `confirm` external

### Step C — テスト

- [x] `tests/plugin_dialog_signature.res` — 8 関数 + 4 variant 値の型レベル網羅
- [x] `tests/runtime/plugin_dialog.test.mjs` — 9 ケース（open*4 + cancel + options + save + message + ask + confirm）

## Phase 3: 検証

- [x] `pnpm install` で workspace に plugin-dialog が認識される
- [x] `pnpm --filter @rescript-tauri/plugin-dialog build` 成功
- [x] `pnpm --filter @rescript-tauri/plugin-dialog test` 成功
- [x] `pnpm --recursive build` で core / schema / plugin-fs に regression なし
- [x] `pnpm --recursive test` 全件パス

## Phase 4: ドキュメント更新

- [x] `docs/repository-structure.md` §2.2 に plugin-dialog セクション追記

## Phase 5: コミット

- [x] パッケージ + ステアリング + docs を機能単位でコミット
- [x] tasklist.md 更新を最終コミットに含める

## Phase 6: マージ

- [x] AskUserQuestion で main マージ可否確認
- [x] 承認後、worktree マージ・クリーンアップ手順に従い実行
- [x] クリーンアップ完了の検証（`git worktree list` / `git branch --list 'worktree-*'` / `.claude/worktrees/`）
