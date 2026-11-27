# 機能追加

`AGENTS.md` と `.claude/rules/issue-workflow.md` を読み、対応する GitHub Issue を特定する。重複がなければ必要な Issue を作り、範囲・対象外・検証可能な DoD を記録する。未決の承認対象は保留する。

専用ブランチ / worktree で `.claude/skills/add-feature/SKILL.md` の機能設計・実装・検証手順を使う。検証した DoD だけを完了にし、結果と残件を Issue / PR にリンクする。
