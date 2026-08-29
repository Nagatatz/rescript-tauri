# Requirements: Claude Code Insights Improvements

| 項目 | 内容 |
|---|---|
| 起票 | 2026-05-09 |
| 起票者 | Nagatatz |
| ステアリング ID | 20260509-053 |
| 関連 | `~/.claude/usage-data/report.html` (599 messages / 82 sessions / 14 日) |

## 1. 背景

`~/.claude/usage-data/report.html` の Insights レポートで指摘された頻発フリクションのうち、本プロジェクトの既存 `.claude/rules/` と `.claude/skills/` でカバーされていない項目を補強する。

具体的に対処する痛みポイント（レポート抜粋）:

- **Worktree が stale な origin/main から分岐される**: 「required a merge to pull in steering commits」が報告。
- **steering 番号衝突**: 「039 collided with concurrent work and had to be renamed to 040」「021 vs 027 confusion」など期間中に複数回発生。
- **state を verify せず主張**: 「commits unpushed と誤主張」「@types/node bump を unexpected と flag」。
- **usage limit による中断**: 「翻訳 / API カバー / refactor が partial で残った」。
- **CI failure / Biome の手動再実行**: 9 セッションが CI debug、Biome `check:fix` が手動依存。
- **disk space crisis**: 「119MB まで圧迫、cache 削除を classifier がブロック」。
- **複数 plugin / template の sequential 実装**: 並列化されていない。
- **coverage の改善ループが usage limit で寸断**: 96 tests を一括追加した後、続きが失われた。

## 2. 目的

- 上記フリクションを Claude Code の **rule + skill + hook** の組み合わせで防止 / 自動化する。
- 既存規約と整合させ、`.claude/rules/` への追加、`CLAUDE.md` の @import 更新、`.claude/skills/` 配下の新規スキル、`.claude/settings.json` の hook 設定を行う。

## 3. スコープ

### In-scope（本ステアリングで実装）

| # | 種別 | 配置 | 概要 |
|---|---|---|---|
| 1 | rule 追加 | `.claude/rules/steering-workflow.md` | Worktree 作成前の `git fetch origin` 強制 |
| 2 | rule 追加 | `.claude/rules/steering-workflow.md` | ステアリング番号衝突防止手順 |
| 3 | rule 新規 | `.claude/rules/pre-flight-verification.md` | repo state を主張する前の検証義務 |
| 4 | rule 追加 | `.claude/rules/steering-workflow.md` | 大規模タスクの checkpoint 計画ルール |
| 5 | hook 新規 | `.claude/settings.json` | PostToolUse Biome auto-format + PreToolUse disk space check |
| 8 | skill 新規 | `.claude/skills/parallel-implementation-swarm/` | 並列 worktree 実装 coordinator パターン |
| 9 | skill 新規 | `.claude/skills/coverage-climber/` | カバレッジ自動 climb ループ |

### Out-of-scope（本ステアリングでは扱わない）

- **#6 (PreToolUse disk space hook 単体)**: #5 に統合。
- **#7 (Headless mode CI triage)**: 別途コスト評価したうえで個別ステアリングで導入判断。本ステアリングでは扱わない。
- 既存の `worktree-safety` / `bash-safety` / `steering` skill との重複部分は新規作成せず、参照リンクで連携する。

## 4. 受け入れ基準

- [ ] `.claude/rules/steering-workflow.md` に「Worktree 鮮度チェック」「番号衝突防止」「checkpoint 計画」セクションが追加されている
- [ ] `.claude/rules/pre-flight-verification.md` が新規作成され、`CLAUDE.md` から `@import` されている
- [ ] `.claude/settings.json` が新規作成され、PostToolUse / PreToolUse の hook が定義されている
- [ ] `.claude/skills/parallel-implementation-swarm/SKILL.md` が新規作成されている
- [ ] `.claude/skills/coverage-climber/SKILL.md` が新規作成されている
- [ ] `pnpm run check` が pass する（追加した JSON / md は Biome / 既存 lint 規約と整合）
- [ ] `tasklist.md` の全タスクが `[x]` になっている

## 5. 非機能要件

- **後方互換性**: 既存セッションを破壊しない（rule 追加は累積、hook は失敗しても build を止めない `|| true` を含める）。
- **テスト省略**: rule / skill / hook はドキュメント・設定ファイルであり ReScript / vitest テスト対象外。検証は `pnpm run check` と JSON 妥当性チェックで代替する（→ `testing.md` の例外条項）。

## 6. 参考

- `~/.claude/usage-data/report.html` Suggested CLAUDE.md Additions セクション
- `.claude/rules/steering-workflow.md` 既存内容
- `.claude/skills/worktree-safety/`、`.claude/skills/bash-safety/` の構造
