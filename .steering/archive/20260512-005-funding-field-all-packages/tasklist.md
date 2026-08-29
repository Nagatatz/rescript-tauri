# Tasklist — funding フィールドを全パッケージに追加

## Phase 1: 計画

- [x] ステアリングディレクトリ作成
- [x] `requirements.md` 作成
- [x] `design.md` 作成
- [x] `tasklist.md` 作成
- [x] ユーザー承認取得 (requirements / design / tasklist 一括) — 2026-05-12
- [x] EnterWorktree で worktree 作成 — `worktree-funding-field-all-packages`

## Phase 2: 実装

- [x] `packages/core/package.json` に `funding` フィールド追加
- [x] `packages/plugin-fs/package.json` に `funding` フィールド追加
- [x] `packages/plugin-dialog/package.json` に `funding` フィールド追加
- [x] `packages/plugin-shell/package.json` に `funding` フィールド追加
- [x] `packages/plugin-notification/package.json` に `funding` フィールド追加
- [x] `packages/plugin-log/package.json` に `funding` フィールド追加
- [x] `packages/plugin-os/package.json` に `funding` フィールド追加
- [x] `packages/plugin-clipboard-manager/package.json` に `funding` フィールド追加
- [x] `packages/plugin-http/package.json` に `funding` フィールド追加
- [x] `packages/schema/package.json` に `funding` フィールド追加

## Phase 3: 検証

- [x] 10 ファイルすべてに `funding` フィールドが正しく存在することを `grep -c '"funding"' packages/*/package.json` で確認 → 全件 `:1`
- [x] JSON 構文検証 (`node -e "JSON.parse(...)"`) → 全件 OK
- [x] Biome check (`pnpm exec biome check packages/*/package.json`) → 10 ファイル format 違反なし
- [x] ~~`pnpm --recursive build`~~ → **スキップ**: 本変更は npm registry metadata (`funding`) のみで ReScript compiler / tsc / vitest のいずれも `funding` フィールドを読まない。ディスク使用率 94% で worktree 内の新規ビルド成果物展開を回避。JSON 構文 + Biome format で十分代替

## Phase 4: コミット

- [x] 単一コミットにまとめる（10 ファイル + steering 3 ファイル）
- [x] コミットメッセージ: `🔧 Add funding field to all 10 packages`

## Phase 5: マージ

- [x] tasklist.md の全タスクを `[x]` に更新（マージタスク自体含む）
- [x] AskUserQuestion で main マージ可否を確認
- [x] main にマージ（`--no-ff`）
- [x] worktree 削除 (`git worktree remove`)
- [x] worktree ブランチ削除 (`git branch -d`)
- [x] クリーンアップ検証 (`git worktree list` / `git branch --list 'worktree-*'` / `ls .claude/worktrees/`)

## テスト省略の理由

`funding` フィールドは npm registry の metadata のみで、ランタイム挙動・型・パッケージ表面に影響しない。既存テスト (型レベル + vitest) はすべての package で実行可能だが、本変更で fail / pass が変化することは無いため、JSON 構文 + Biome format check の green confirmation で代替する。
