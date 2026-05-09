# Tasklist: Claude Code Insights Improvements

## Phase 1: 計画

- [x] requirements.md を作成
- [x] design.md を作成
- [x] tasklist.md を作成（本ファイル）
- [ ] EnterWorktree で隔離環境を作成

## Phase 2: 実装（worktree 内）

### #1 #2 #4 — `steering-workflow.md` 拡張

- [ ] worktree 作成前の `git fetch origin` 鮮度チェック手順を追記
- [ ] ステップ 1 のステアリング番号採番手順を更新（`ls + sort | tail -1` + 衝突確認）
- [ ] 「長時間タスクの Checkpoint 計画」サブセクションを追記

### #3 — `pre-flight-verification.md` 新規

- [ ] `.claude/rules/pre-flight-verification.md` を新規作成
- [ ] CLAUDE.md の @import チェーンに追加
- [ ] テスト省略理由を本ファイルに明記（ドキュメントのため `testing.md` 例外）

### #5 — Hooks (`.claude/settings.json` + `.claude/hooks/*.sh`)

- [ ] `.claude/hooks/check-disk-space.sh` を新規作成（PreToolUse Bash 用）
- [ ] `.claude/hooks/biome-format.sh` を新規作成（PostToolUse Edit/Write 用）
- [ ] 両スクリプトに実行権限付与 (`chmod +x`)
- [ ] `.claude/settings.json` を新規作成し hook を登録
- [ ] `bash -n` で構文チェック
- [ ] テスト省略理由を本ファイルに明記（hook の挙動はランタイム依存、`testing.md` 例外）

### #8 — `parallel-implementation-swarm` skill

- [ ] `.claude/skills/parallel-implementation-swarm/SKILL.md` を新規作成
- [ ] YAML frontmatter (`name`, `description`) を含める
- [ ] 番号予約 / coordinator / batch merge の手順を記述

### #9 — `coverage-climber` skill

- [ ] `.claude/skills/coverage-climber/SKILL.md` を新規作成
- [ ] state file `.claude/coverage-progress.json` 設計を記述
- [ ] gitignore 更新指示を skill 本文に記載
- [ ] ガードレール（production code 変更禁止 等）を明記

### ドキュメント更新

- [ ] `docs/repository-structure.md` に `.claude/hooks/`、`.claude/skills/` の新規追加を反映
- [ ] `CLAUDE.md` の「状況発火型の知識 (skills)」表に新規 skill 2 件を追加

## Phase 3: 検証

- [ ] `jq . .claude/settings.json` で JSON 妥当性確認
- [ ] `bash -n .claude/hooks/*.sh` で hook 構文確認
- [ ] `head -10` で skill md frontmatter を目視確認
- [ ] `pnpm run check` で Biome lint pass を確認

## Phase 4: コミット & マージ前

- [ ] 適切な粒度（rule 系 / hook 系 / skill 系で分割）でコミット
- [ ] tasklist.md を全 [x] にしてからマージ前最終コミット
- [ ] AskUserQuestion で main マージ可否を確認

## Phase 5: マージ後

- [ ] main にマージ
- [ ] `git worktree remove` で worktree 削除
- [ ] `git branch -d` でブランチ削除
- [ ] クリーンアップ完了の検証（`git worktree list` / `git branch --list 'worktree-*'` / `ls .claude/worktrees/`）

## テスト省略理由

本ステアリングの成果物はすべて **ドキュメント・設定ファイル・shell hook** であり、ReScript / vitest の自動テスト対象外（`testing.md` 例外条項「外部サービスとの結合が必須で単体テストが困難なクラス」に類する）。代替検証として:

- JSON 妥当性: `jq`
- hook syntax: `bash -n`
- markdown frontmatter: 目視確認
- 全体 lint: `pnpm run check`
